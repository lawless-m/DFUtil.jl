module DFUtil

using DataFrames
using Dates

export sum_columns, group_data_into_periods, match_row, to_json, to_json_var

"""
	sum_columns(df, group_by::Vector{String}=Vector{String}())

	sum the columns of the dataframe, optionally grouping by group_by

# Arguments

- `df` DataFrame to sum
- `group_by` Vector of String names of the columns to group by
- `replace_with` by default DataFrames takes the column names and appends _function. Instead use this string.
"""
function sum_columns(df; group_by::Vector{String}=Vector{String}(), replace_with="s") 
	buffer = combine(groupby(df, group_by),  [ c => c->sum(skipmissing(c)) for c in filter(n->!(n in group_by), names(df)) ])
	rename!(buffer, map(c-> c=>replace(c, "_function"=>replace_with), names(buffer)))
end	

"""
	group_data_into_periods(df::DataFrame, date_column::Union{Symbol, AbstractString}, period::Union{Symbol, AbstractString}; andgrpby = Vector{String}())

	Using the given data_column, group the dataframe into periods.

	All columns except the grouping ones *must* have methods for +

# Arguments
- `df` DataFrame to group
- `date_column` the column to use as the grouping
- `period` Period to use, options are: :Qtr, :Month, :Year, :Week (or as strings)
- `andgrpby` optional keyword to use additional groupings

# Examples
	`group_data_into_periods(df, :SaleDate, :Week)`
	`group_data_into_periods(df, "SaleDate", :Year, "BranchId")`
	`group_data_into_periods(df, :SaleDate, "Qtr", [:Area, :BranchId)]`
"""
function group_data_into_periods(df, date_column, period; andgrpby=Vector{String}())
	if isa(period, String)
		period = Symbol(period)
	end
	if isa(andgrpby, String) || isa(andgrpby, Symbol) 
		andgrpby = [andgrpby]
	end

	period_fns = Dict(
		:Qtr   => dt-> ismissing(dt) ? missing : string(Dates.year(dt)) * "Q" * string(Dates.quarterofyear(dt)),
		:Month => dt-> ismissing(dt) ? missing : string(Dates.year(dt)) * "-" * ("00" * string(Dates.month(dt)))[end-1:end],
		:Year  => dt-> ismissing(dt) ? missing : string(Dates.year(dt)),
		:Week  => dt-> ismissing(dt) ? missing : string(Dates.year(dt)) * "-" * ("00" * string(Dates.week(dt)))[end-1:end],
	)
	
	sum_columns(select(transform(df, date_column => ByRow(dt -> period_fns[period](dt))), Not(date_column)), group_by=vcat(andgrpby, ["$(date_column)_function"]))
end

"""
match_row(df, col, val) 

Just a shortcut for filter(row -> row[col] == val, df)

Not even sure why I introduced it	
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
"""
function to_json_var(io::IO, df::DataFrame, keys, var="object")
	print(io, "var $var=JSON.parse('")
	to_json(io, df, keys)
	println(io, "');");
end

"""
	to_json(io::IO, data::DataFrame, keys::Union{AbstractString, Vector{AbstractString}})

	Output the dataframe to Json, grouping by the given keys

	`{ "row[keys[1]]" : { "row[keys[2]]" : { "names(row)[1]" : "row[names(row[1])]", "names(row)[2]" : "row[names(row[2])]", ..., "names(row)[end]" : "row[names(row[end])]"}}}`
	
# Arguments
- `io` IO handle to write to
- `df` DataFrame to write
- `keys` Keys to lift outside the object
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
			_to_json(io, groupby(grp, keys[depth+1]), keys, depth=depth+1)
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