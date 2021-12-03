var documenterSearchIndex = {"docs":
[{"location":"#DFUtil.jl","page":"DFUtil.jl","title":"DFUtil.jl","text":"","category":"section"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"Documentation for DFUtil.jl","category":"page"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"sum_columns","category":"page"},{"location":"#DFUtil.sum_columns","page":"DFUtil.jl","title":"DFUtil.sum_columns","text":"sum_columns(df, group_by::Vector{String}=Vector{String}())\n\nSum the columns of the dataframe, optionally grouping by group_by\n\nAll the columns not in the grouping must have a + method\n\nArguments\n\ndf DataFrame to sum\ngroup_by Vector of String names of the columns to group by\nreplace_with by default DataFrames takes the column names and appends _function. Instead use this string.\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"group_data_into_periods","category":"page"},{"location":"#DFUtil.group_data_into_periods","page":"DFUtil.jl","title":"DFUtil.group_data_into_periods","text":"group_data_into_periods(df::DataFrame, date_column::Union{Symbol, AbstractString}, period::Union{Symbol, AbstractString}; andgrpby = Vector{String}())\n\nUsing the given data_column, group the dataframe into periods.\n\nAll columns except the grouping ones must have methods for +`\n\nArguments\n\ndf DataFrame to group\ndate_column the column to use as the grouping\nperiod Period to use, options are: :Quarter, :Month, :Year, :Week (or as strings)\nandgrpby optional keyword to use additional groupings\n\nExamples\n\ngroup_data_into_periods(df, :SaleDate, :Week)\ngroup_data_into_periods(df, \"SaleDate\", :Year, \"BranchId\")\ngroup_data_into_periods(df, :SaleDate, \"Quarter\", [:Area, :BranchId)]\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"pQuarter","category":"page"},{"location":"#DFUtil.pQuarter","page":"DFUtil.jl","title":"DFUtil.pQuarter","text":"pQuarter(dt)\n\nturn a Date / Datetime into its eqivalent YearQn representation e.g. 2001Q1\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"pWeek","category":"page"},{"location":"#DFUtil.pWeek","page":"DFUtil.jl","title":"DFUtil.pWeek","text":"pWeek(dt)\n\nTurn a Date / Datetime into its eqivalent YearWeek representation e.g. 2001-01 Preserves 2000-01-01 becoming 1999-52\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"pYear","category":"page"},{"location":"#DFUtil.pYear","page":"DFUtil.jl","title":"DFUtil.pYear","text":"pYear(dt)\n\nturn a Date / Datetime into its eqivalent Year representation e.g. 2001\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"pMonth","category":"page"},{"location":"#DFUtil.pMonth","page":"DFUtil.jl","title":"DFUtil.pMonth","text":"pMonth(dt)\n\nturn a Date / Datetime into its eqivalent YearMonth representation e.g. 2001-01\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"match_row","category":"page"},{"location":"#DFUtil.match_row","page":"DFUtil.jl","title":"DFUtil.match_row","text":"match_row(df, col, val)\n\nJust a shortcut for filter(row -> row[col] == val, df)\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"to_json","category":"page"},{"location":"#DFUtil.to_json","page":"DFUtil.jl","title":"DFUtil.to_json","text":"to_json(io::IO, data::DataFrame, keys::Union{AbstractString, Vector{AbstractString}})\n\nOutput the dataframe to Json, grouping by the given keys\n\n{ \"row[keys[1]]\" : { \"row[keys[2]]\" : { \"names(row)[1]\" : \"row[names(row[1])]\", \"names(row)[2]\" : \"row[names(row[2])]\", ..., \"names(row)[end]\" : \"row[names(row[end])]\"}}}\n\nThe motivation for this is to enable referencing the objects via their nested keys in JavaScript\n\njulia> df = DataFrame([[10, 10, 11], [1, 2, 3], [\"Fred\", \"Luke\", \"Alice\"]], [\"Area\", \"EmpId\", \"Name\"])\n3×3 DataFrame\n Row │ Area   EmpId  Name\n\t │ Int64  Int64  String\n─────┼──────────────────────\n   1 │    10      1  Fred\n   2 │    10      2  Luke\n   3 │    11      1  Alice\n\n   julia> to_json(stdout, df, [\"Area\", \"EmpId\"])\n   \n   { \"10\" : {\"1\" : {\"Area\" : \"10\", \"EmpId\" : \"1\", \"Name\" : \"Fred\" } , \"2\" : {\"Area\" : \"10\", \"EmpId\" : \"2\", \"Name\" : \"Luke\" }  }, \"11\" : {\"3\" : {\"Area\" : \"11\", \"EmpId\" : \"3\", \"Name\" : \"Alice\" }  } }\n\nin Javascript\n\nlet fred = object[10][1]\t\nlet luke = object[10][2]\t\t\nlet alice = object[11][1]\n\nArguments\n\nio IO handle to write to\ndf DataFrame to write\nkeys Keys to lift outside the object\n\nExamples\n\ndf = DataFrame([[1,2],[3,4],[4,5]],[\"a\", \"b\", \"c\"]), \"a\")\n\nto_json(stdout, df, \"a\")\n\n\"{ \"1\" : {\"a\" : \"1\", \"b\" : \"3\", \"c\" : \"4\" } , \"2\" : {\"a\" : \"2\", \"b\" : \"4\", \"c\" : \"5\" }  }\"\n\nto_json(stdout, df, [\"a\", \"b\"])\n\n\"{ \"1\" : {\"3\" : {\"a\" : \"1\", \"b\" : \"3\", \"c\" : \"4\" }  }, \"2\" : {\"4\" : {\"a\" : \"2\", \"b\" : \"4\", \"c\" : \"5\" }  } }\")\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"to_json_var","category":"page"},{"location":"#DFUtil.to_json_var","page":"DFUtil.jl","title":"DFUtil.to_json_var","text":"to_json_var(io::IO, df::DataFrame, keys::Union{AbstractString, Vector{AbstractString}}, var=\"object\")\n\nOutput the dataframe to json using to_json but wrap it inside a Javascript JSON.parse() for direct use in Javascript\n\nArguments\n\nio IO handle to write to\ndf DataFrame to write\nkeys Keys to lift outside the object - see to_json for explanation of that\nvar JavaScript object name it will be assign to with var $var = ....\n\nExamples\n\ndf = DataFrame([[1,2],[3,4],[4,5]],[\"a\", \"b\", \"c\"]), \"a\")\n\nto_json_var(stdout, df, \"a\", \"object\")\n\n\"var object = JSON.parse('{ \"1\" : {\"a\" : \"1\", \"b\" : \"3\", \"c\" : \"4\" } , \"2\" : {\"a\" : \"2\", \"b\" : \"4\", \"c\" : \"5\" }  }');\"\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"to_js_value","category":"page"},{"location":"#DFUtil.to_js_value","page":"DFUtil.jl","title":"DFUtil.to_js_value","text":"to_js_value(io::IO, df::DataFrame, keys::Union{AbstractString, Vector{AbstractString}}, jsdeclaration=\"var object\")\n\nOutput the dataframe to json using to_json but wrap it inside a Javascript JSON.parse() for direct use in Javascript\n\nArguments\n\nio IO handle to write to\ndf DataFrame to write\nkeys Keys to lift outside the object - see to_json for explanation of that\nvar JavaScript object name it will be assign to with var $var = ....\n\nExamples\n\ndf = DataFrame([[1,2],[3,4],[4,5]],[\"a\", \"b\", \"c\"]), \"a\")\n\nto_js_value(stdout, df, \"a\", \"export const vals\")\n\n\"export const vals = JSON.parse('{ \"1\" : {\"a\" : \"1\", \"b\" : \"3\", \"c\" : \"4\" } , \"2\" : {\"a\" : \"2\", \"b\" : \"4\", \"c\" : \"5\" }  }');\"\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"include_or_exclude","category":"page"},{"location":"#DFUtil.include_or_exclude","page":"DFUtil.jl","title":"DFUtil.include_or_exclude","text":"include_or_exclude(df, includes, excludes)\n\nGiven a DataFrame either restrict it to the includes list, or remove the exludes list\n\nSounds a bit daft but it is to provide KW options in functions\n\nIf both are given, the includes take priority\n\nArguments\n\ndf the DataFrame\nincludes the String, Symbol or list of those to include\nexcludes the String, Symbol or list of those to exclude\n\nExamples\n\ndf = DataFrame([[1,2,3], [10,20,30]], [\"a\", \"b\"])\n\njulia> include_or_exclude(df, includes=[\"a\"])\n3×1 DataFrame\nRow │ a\n\t│ Int64\n─────┼───────\n1 │     1\n2 │     2\n3 │     3\n\n\njulia> include_or_exclude(df, excludes=\"a\")\n3×1 DataFrame\nRow │ b\n\t│ Int64\n─────┼───────\n1 │    10\n2 │    20\n3 │    30\n\n\njulia> include_or_exclude(df, includes=[\"a\"], excludes=[\"a\", \"b\"])\n3×1 DataFrame\nRow │ a\n\t│ Int64\n─────┼───────\n1 │     1\n2 │     2\n3 │     3\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"nthrow","category":"page"},{"location":"#DFUtil.nthrow","page":"DFUtil.jl","title":"DFUtil.nthrow","text":"nthrow(df)\n\nReturn the nth row of a dataframe as a DataFrameRow, if n is out of bounds, return nothing\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"firstrow","category":"page"},{"location":"#DFUtil.firstrow","page":"DFUtil.jl","title":"DFUtil.firstrow","text":"firstrow(df)\n\nReturn the first row as a DataFrameRow\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"lastrow","category":"page"},{"location":"#DFUtil.lastrow","page":"DFUtil.jl","title":"DFUtil.lastrow","text":"lastrow(df)\n\nReturn the last row of df as a DataFrameRow\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"exclude_rows","category":"page"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"de_miss_rows","category":"page"},{"location":"#DFUtil.de_miss_rows","page":"DFUtil.jl","title":"DFUtil.de_miss_rows","text":"de_miss_rows(df)\n\nFor a given DataFrame, remove any rows in which any column has a missing value\n\nExamples\n\ndf = DataFrame([[1,missing,3], [10,20,30]], [\"a\", \"b\"])\n3×2 DataFrame\n Row │ a        b\n\t │ Int64?   Int64?\n─────┼─────────────────\n   1 │       1      10\n   2 │ missing      20\n   3 │       3      30\n\t\njulia> dm = de_miss_rows(df)\n2×2 DataFrame\n Row │ a       b\n\t │ Int64?  Int64?\n─────┼────────────────\n   1 │      1      10\n   2 │      3      30\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"to_csv_text","category":"page"},{"location":"#DFUtil.to_csv_text","page":"DFUtil.jl","title":"DFUtil.to_csv_text","text":"to_csv_text(df)\n\nturn the dataframe into the string representation of the CSV\n\nExamples\n\ndf = DataFrame(\n[[53.685335, 53.785335, 53.885335],\n[-0.416387,-0.426387,-0.436387],\n[53.479544, 53.479544,53.479544],\n[-2.954101,-2.954101,-2.954101]], [\"lat1\", \"lon1\", \"lat2\", \"lon2\"])\n\nto_csv_text(df)\n\"lat1,lon1,lat2,lon2\\n53.685335,-0.416387,53.479544,-2.954101\\n53.785335,-0.426387,53.479544,-2.954101\\n53.885335,-0.436387,53.479544,-2.954101\\n\"\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"from_csv_text","category":"page"},{"location":"#DFUtil.from_csv_text","page":"DFUtil.jl","title":"DFUtil.from_csv_text","text":"from_csv_text(csv_text)\n\nCreate a dataframe from the string represenation of a CSV\n\nExamples\n\nfrom_csv_text(\"lat1,lon1,lat2,lon2\\n53.685335,-0.416387,53.479544,-2.954101\\n53.785335,-0.426387,53.479544,-2.954101\\n53.885335,-0.436387,53.479544,-2.954101\\n\")\n\n3×4 DataFrame\nRow │ lat1     lon1       lat2     lon2\n\t│ Float64  Float64    Float64  Float64\n\n─────┼────────────────────────────────────── \t  1 │ 53.6853  -0.416387  53.4795  -2.9541 \t  2 │ 53.7853  -0.426387  53.4795  -2.9541 \t  3 │ 53.8853  -0.436387  53.4795  -2.9541\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"concat!","category":"page"},{"location":"#DFUtil.concat!","page":"DFUtil.jl","title":"DFUtil.concat!","text":"concat!(df, args...)\n\nAll of the dataframes supplied as args, appended to df\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"leftjoiner","category":"page"},{"location":"#DFUtil.leftjoiner","page":"DFUtil.jl","title":"DFUtil.leftjoiner","text":"leftjoiner(df, on, args...; kw...)\n\nArguments\n\ndf The initial DataFrame\non The field(s) to join with\nargs... The DataFrames to join to the df\nkw... KW args passed to leftjoin\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"tryRename","category":"page"},{"location":"#DFUtil.tryRename","page":"DFUtil.jl","title":"DFUtil.tryRename","text":"tryRename(df, renamelist)\ntryRename!(df, renamelist)\n\nAttempts to renames the given fields, however, unlike DataFrames.rename, doesn't complain if the column doesn't exist\n\n\n\n\n\n","category":"function"},{"location":"","page":"DFUtil.jl","title":"DFUtil.jl","text":"dropByName!","category":"page"}]
}
