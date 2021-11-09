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
	buffer = combine(group_by == [] ? df : groupby(df, group_by),  [ c => c->sum(skipmissing(c)) for c in filter(n->!(n in group_by), names(df)) ])
	rename(buffer, map(c-> c=>replace(c, "_function"=>replace_with), names(buffer)))
end	

function group_data_into_periods(df, date_column, period; andgrpby = Vector{String}())
	
	period_fns = Dict(
		"Qtr" => dt->string(Dates.year(dt)) * "Q" * string(Dates.quarterofyear(dt)),
		"Month" => dt->string(Dates.year(dt)) * "-" * ("00" * string(Dates.month(dt)))[end-1:end],
		"Year" => dt->string(Dates.year(dt)),
		"Week" => dt->string(Dates.year(dt)) * "-" * ("00" * string(Dates.week(dt)))[end-1:end],
	)
	
	df[!, date_column * "_period"] = map(dt->period_fns[period](dt), df[!, date_column])  

	sum_columns(select(df, Not(date_column)), group_by=vcat(andgrpby, [date_column * "_period"]))
	
end

function match_row(df, col, val)
	filter(row -> row[col] == val, df)
end

jesc(v) = replace(string(v), "'"=>"\\'")
kesc(k) = replace(jesc(k), " "=>"")

print_term(io, row, key, prefix="") = print(io, prefix, "\"$(kesc(key))\" : ", "\"$(jesc(row[key]))\""); 

function print_terms(io, row)
	print_term(io, row, names(row)[1], "")
	broadcast(term -> print_term(io, row, term, ", "), names(row)[2:end]);
end

function print_data_row(io, row, pkey, prefix="")
	print(io, prefix, "\"$(kesc(row[pkey]))\" : {")
	print_terms(io, row)
	print(io, " } ");
end

function to_jsonX(io::IO, data::DataFrame, pkey::AbstractString)
	print(io, "{ ")
	print_data_row(io, eachrow(data)[1], pkey)
	broadcast(row->print_data_row(io, row, pkey; prefix=", "), eachrow(data)[2:end])
	print(io, " }");
end

function to_json_var(io::IO, data::DataFrame, pkeys, var="object")
	print(io, "var $var=JSON.parse('")
	to_json(io, data, isa(pkey, Array) ? pkey : [pkey])
	println(io, "');");
end

function to_json(io::IO, data::DataFrame, keys)
	print(io, "{ ")
	if isa(keys, Array)
		to_json(io, groupby(data, keys[1]), keys, depth=1)
	else
		to_json(io, groupby(data, keys), [keys], depth=1)
	end
	print(io, " }")
end

function to_json(io::IO, data, keys; depth=1)
	prefix = ""
	if depth == length(keys)
		for grp in data
			print_data_row(io, eachrow(grp)[1], keys[depth], prefix)
			prefix=", "
		end
	else
		for grp in data 
			k = kesc(grp[!, keys[depth]][1])
			print(io, prefix, "\"$k\" : {")
			to_json(io, groupby(grp, keys[depth+1]), keys, depth=depth+1)
			print(io, " }");
			prefix = ", "
		end
	end
end


###
end