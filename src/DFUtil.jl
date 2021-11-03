module DFUtil

using DataFrames
using Dates

export sum_columns, group_data_into_periods, match_row, to_json

function sum_columns(df, group_by::Vector{String}) 
	buffer = combine(groupby(df, group_by),  [ c => c->sum(skipmissing(c)) for c in filter(n->!(n in group_by), names(df)) ])
	rename(buffer, map(c-> c=>replace(c, "_function"=>"s"), names(buffer)))
end	

function group_data_into_periods(df, date_column, period; andgrpby = Vector{String}())
	
	period_fns = Dict(
		"Qtr" => dt->string(Dates.year(dt)) * "Q" * string(Dates.quarterofyear(dt)),
		"Month" => dt->string(Dates.year(dt)) * "-" * ("00" * string(Dates.month(dt)))[end-1:end],
		"Year" => dt->string(Dates.year(dt)),
		"Week" => dt->string(Dates.year(dt)) * "-" * ("00" * string(Dates.week(dt)))[end-1:end],
	)
	
	df[!, date_column * "_period"] = map(dt->period_fns[period](dt), df[!, date_column])  

	sum_columns(select(df, Not(date_column)), vcat(andgrpby, [date_column * "_period"]))
	
end

function match_row(df, col, val)
	filter(row -> row[col] == val, df)
end

jesc(v) = replace(string(v), "'"=>"\\'")
kesc(k) = replace(jesc(k), " "=>"")

print_term(io, row, key; prefix="") = print(io, prefix, "\"$(kesc(key))\" : ", "\"$(jesc(row[key]))\""); 

function print_data_row(io, row, pkey, exports; prefix="")
	print(io, prefix, "\"$(kesc(row[pkey]))\" : {")
	print_term(io, row, exports[1])
	broadcast(term -> print_term(io, row, term; prefix=", "), exports[2:end]);
	print(io, " } ")
end

function to_json(io::IO, data::DataFrame, pkey::AbstractString)
	exports = filter(k->k!=pkey, names(data))
	print(io, "{ ")
	print_data_row(io, eachrow(data)[1], pkey, exports)
	broadcast(row->print_data_row(io, row, pkey, exports; prefix=", "), eachrow(data)[2:end])
	print(io, " }")
end


###
end