module DFUtil

using DataFrames
using Dates
using Pipe

export sum_columns, group_data_into_periods, match_row, to_json, to_json_var, include_or_exclude
export pQtr, pWeek, pYear, pMonth

function force_vector(v)
	if isa(v, String) || isa(v, Symbol)
		return [v]
	end
	v = collect(Iterators.flatten([v]))
	return isa(v, Vector) ? v : [v]
end

"""
	include_or_exclude(df, includes, excludes)

Given a DataFrame either restrict it to the includes list, or remove the exludes list

Sounds a bit daft but it is to provide KW options in functions

If both are given, the `includes` take priority

# Arguments
- `df` the DataFrame
- `includes` the String, Symbol or list of those to include
- `excludes` the String, Symbol or list of those to exclude

# Examples

	df = DataFrame([[1,2,3], [10,20,30]], ["a", "b"])

	include_or_exclude(df, includes="a")

	julia> include_or_exclude(df, includes=["a"])
	3×1 DataFrame
	Row │ a
		│ Int64
	─────┼───────
	1 │     1
	2 │     2
	3 │     3

	
	julia> include_or_exclude(df, excludes="a")
	3×1 DataFrame
	Row │ b
		│ Int64
	─────┼───────
	1 │    10
	2 │    20
	3 │    30

	
	julia> include_or_exclude(df, includes=["a"], excludes=["a", "b"])
	3×1 DataFrame
	Row │ a
		│ Int64
	─────┼───────
	1 │     1
	2 │     2
	3 │     3

"""	
function include_or_exclude(df; includes=nothing, excludes=nothing)
	if excludes == nothing && includes == nothing
		return df
	end

	if excludes == nothing
		# force vector to makes sure it returns a DataFrame
		return df[!, force_vector(includes)] 
	end

	if includes == nothing
		return df[!, Not(excludes)]
	end
	# we have includes *and* excludes. 
	# Includes take priority

	# makes sure they are both lists, and the same datatype
	includes = map(i->string(i), force_vector(includes))
	excludes = map(e->string(e), force_vector(excludes))

	return df[!, Not(filter(e->! (e in includes), excludes))]
end
"""
	sum_columns(df, group_by::Vector{String}=Vector{String}())

Sum the columns of the dataframe, optionally grouping by group_by

All the columns not in the grouping *must* have a `+` method

# Arguments

- `df` DataFrame to sum
- `group_by` Vector of String names of the columns to group by
- `replace_with` by default DataFrames takes the column names and appends _function. Instead use this string.
"""
sum_columns(df; group_by::Vector{String}=Vector{String}(), replace_with="s") = @pipe groupby(df, group_by) |>
		combine(_,  [ c => c->sum(skipmissing(c)) for c in filter(n->!(n in group_by), names(df)) ]) |>
		rename(_, map(c-> c=>replace(c, "_function"=>replace_with), names(_)))

"""
	group_data_into_periods(df::DataFrame, date_column::Union{Symbol, AbstractString}, period::Union{Symbol, AbstractString}; andgrpby = Vector{String}())

Using the given data_column, group the dataframe into periods.

All columns except the grouping ones *must* have methods for `+``

# Arguments
- `df` DataFrame to group
- `date_column` the column to use as the grouping
- `period` Period to use, options are: :Qtr, :Month, :Year, :Week (or as strings)
- `andgrpby` optional keyword to use additional groupings

# Examples
	group_data_into_periods(df, :SaleDate, :Week)
	group_data_into_periods(df, "SaleDate", :Year, "BranchId")
	group_data_into_periods(df, :SaleDate, "Qtr", [:Area, :BranchId)]
"""
function group_data_into_periods(df, date_column, period; andgrpby=Vector{String}())
	if isa(period, String)
		period = Symbol(period)
	end
	if isa(andgrpby, String) || isa(andgrpby, Symbol) 
		andgrpby = [andgrpby]
	end

	period_fns = Dict(:Qtr => pQtr, :Month => pMonth, :Year => pYear, :Week => pWeek)

	@pipe transform(df, date_column => ByRow(dt -> period_fns[period](dt)) => "$(date_column)_function") |>
		select(_, Not(date_column)) |> 
		sum_columns(_, group_by=vcat(andgrpby, ["$(date_column)_function"]))
end

# period functions
"""
	pQtr(dt)

turn a Date / Datetime into its eqivalent YearQn representation e.g. 2001Q1
"""
pQtr(dt)   = ismissing(dt) ? missing : string(Dates.year(dt)) * "Q" * string(Dates.quarterofyear(dt))
"""
pMonth(dt)

turn a Date / Datetime into its eqivalent YearMonth representation e.g. 2001-01
"""
pMonth(dt) = ismissing(dt) ? missing : string(Dates.year(dt)) * "-" * ("00" * string(Dates.month(dt)))[end-1:end]
"""
	pYear(dt)

turn a Date / Datetime into its eqivalent Year representation e.g. 2001
"""
pYear(dt)  = ismissing(dt) ? missing : Dates.year(dt)
"""
	pWeek(dt)

Turn a Date / Datetime into its eqivalent YearWeek representation e.g. 2001-01
Preserves 2000-01-01 becoming 1999-52
"""
function pWeek(dt) # this is the tricky one because 2000-01-01 is 1999-52
	if ismissing(dt) 
		return  missing
	end
	m = Dates.month(dt)
	w = Dates.week(dt)
	y = Dates.year(dt)
	if m == 1 && w > 10 
		y = y - 1
	end
	"$y-" * ("00" * string(w))[end-1:end] # right pad with 0
end
"""
	match_row(df, col, val) 

Just a shortcut for `filter(row -> row[col] == val, df)`

"""
match_row(df, col, val) = filter(row -> row[col] == val, df)


"""
	to_json_var(io::IO, df::DataFrame, keys::Union{AbstractString, Vector{AbstractString}}, var="object")

Output the dataframe to json using to_json but wrap it inside a Javascript JSON.parse() for direct use in Javascript

# Arguments
- `io` IO handle to write to
- `df` DataFrame to write
- `keys` Keys to lift outside the object - see [`to_json`](@ref) for explanation of that
- `var` JavaScript object name it will be assign to with `var \$var = ....`

# Examples

	df = DataFrame([[1,2],[3,4],[4,5]],["a", "b", "c"]), "a")

	to_json_var(stdout, df, "a", "object")

	"var object=JSON.parse('{ \"1\" : {\"a\" : \"1\", \"b\" : \"3\", \"c\" : \"4\" } , \"2\" : {\"a\" : \"2\", \"b\" : \"4\", \"c\" : \"5\" }  }');"
"""
function to_json_var(io::IO, df::DataFrame, keys, var="object")
	print(io, "var $var=JSON.parse('")
	to_json(io, df, keys)
	println(io, "');");
end

"""
	to_json(io::IO, data::DataFrame, keys::Union{AbstractString, Vector{AbstractString}})

Output the dataframe to Json, grouping by the given keys

	{ "row[keys[1]]" : { "row[keys[2]]" : { "names(row)[1]" : "row[names(row[1])]", "names(row)[2]" : "row[names(row[2])]", ..., "names(row)[end]" : "row[names(row[end])]"}}}
	
The motivation for this is to enable referencing the objects via their nested keys in JavaScript

	julia> df = DataFrame([[10, 10, 11], [1, 2, 3], ["Fred", "Luke", "Alice"]], ["Area", "EmpId", "Name"])
	3×3 DataFrame
	 Row │ Area   EmpId  Name
		 │ Int64  Int64  String
	─────┼──────────────────────
	   1 │    10      1  Fred
	   2 │    10      2  Luke
	   3 │    11      1  Alice
	
	   julia> to_json(stdout, df, ["Area", "EmpId"])
	   
	   { "10" : {"1" : {"Area" : "10", "EmpId" : "1", "Name" : "Fred" } , "2" : {"Area" : "10", "EmpId" : "2", "Name" : "Luke" }  }, "11" : {"3" : {"Area" : "11", "EmpId" : "3", "Name" : "Alice" }  } }

in Javascript

	let fred = object[10][1]	
	let luke = object[10][2]		
	let alice = object[11][1]

# Arguments
- `io` IO handle to write to
- `df` DataFrame to write
- `keys` Keys to lift outside the object

# Examples

	df = DataFrame([[1,2],[3,4],[4,5]],["a", "b", "c"]), "a")

	to_json(stdout, df, "a")

	"{ \"1\" : {\"a\" : \"1\", \"b\" : \"3\", \"c\" : \"4\" } , \"2\" : {\"a\" : \"2\", \"b\" : \"4\", \"c\" : \"5\" }  }"

	to_json(stdout, df, ["a", "b"])

	"{ \"1\" : {\"3\" : {\"a\" : \"1\", \"b\" : \"3\", \"c\" : \"4\" }  }, \"2\" : {\"4\" : {\"a\" : \"2\", \"b\" : \"4\", \"c\" : \"5\" }  } }")

"""
function to_json(io, df, keys)
	print(io, "{ ")
	if isa(keys, Array)
		_to_json(io, groupby(df, keys[1]), keys, 1)
	else
		_to_json(io, groupby(df, keys), [keys], 1)
	end
	print(io, " }")
end


# turn the first row of a DF into a DataFrameRow, a helper for _to_json
row(grp) = eachrow(grp)[1]

# helper for to_json
function _to_json(io, data, keys, depth)
	prefix = ""
	if depth == length(keys)
		print_data_row(io, row(data[1]), keys[depth], "")
		for grp in data[2:end]
			print_data_row(io, row(grp), keys[depth], ", ")
	end
	else
		for grp in data 
			k = kesc(grp[!, keys[depth]][1])
			print(io, prefix, "\"$k\" : {")
			_to_json(io, groupby(grp, keys[depth+1]), keys, depth+1)
			print(io, " }");
			prefix = ", "
		end
	end
end


# key / value escapers
jesc(v) = replace(string(v), "'"=>"\\'")
kesc(k) = replace(jesc(k), " "=>"")

# print a key value pair
print_term(io, row, key, prefix="") = print(io, prefix, "\"$(kesc(key))\" : ", "\"$(jesc(row[key]))\""); 

# print all key value pairs, with appropriate comma-ing
function print_terms(io, row)
	print_term(io, row, names(row)[1], "")
	broadcast(term -> print_term(io, row, term, ", "), names(row)[2:end]);
end

# print a compete row, with single pkey
function print_data_row(io, row, pkey, prefix)
	print(io, prefix, "\"$(kesc(row[pkey]))\" : {")
	print_terms(io, row)
	print(io, " } ");
end

###
end