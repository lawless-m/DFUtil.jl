using DFUtil
using Test
using DataFrames
using Dates

df = DataFrame([[1,2],[3,4],[4,5]],["a", "b", "c"])
ddf = DataFrame([[1,2,2],[3,4,2],[4,5,3]], ["a", "b", "c"])
dt = DataFrame([[ Date(2000, 1, 1), Date(2000, 2, 1), Date(2000, 3, 1),Date(2001, 1, 1), Date(2001, 2, 1), Date(2001, 3, 1),Date(2001, 12, 1), Date(2001, 7, 1), Date(2001, 12, 31),Date(2002, 1, 1),Date(2002, 2, 1),Date(2002, 3, 1)],[1,1,1,1,1,1,1,1,1,1,1,1],[2,2,2,2,2,2,2,2,2,2,2,2]], ["d", "b", "c"])

dfab = DataFrame([[1,2,3], [4,5,6]], ["a", "b"])
dfac = DataFrame([[1,2,3], [4,5,6]], ["a", "c"])
dfad = DataFrame([[1,2,3], [4,5,6]], ["a", "d"])
dfabcd = DataFrame([[1,2,3], [4,5,6], [4,5,6], [4,5,6]], ["a", "b", "c", "d"])

stdtest = IOBuffer()
eq(_, t) = String(take!(stdtest)) == t

@testset "DFUtil.jl" begin
    @test eq(to_json(stdtest, df, "a"), "{ \"1\" : {\"a\" : \"1\", \"b\" : \"3\", \"c\" : \"4\" } , \"2\" : {\"a\" : \"2\", \"b\" : \"4\", \"c\" : \"5\" }  }")
    @test eq(to_json(stdtest, df, ["a", "b"]), "{ \"1\" : {\"3\" : {\"a\" : \"1\", \"b\" : \"3\", \"c\" : \"4\" }  }, \"2\" : {\"4\" : {\"a\" : \"2\", \"b\" : \"4\", \"c\" : \"5\" }  } }")
    @test eq(to_json_var(stdtest, df, ["a", "b"],"test"), "var test = JSON.parse('{ \"1\" : {\"3\" : {\"a\" : \"1\", \"b\" : \"3\", \"c\" : \"4\" }  }, \"2\" : {\"4\" : {\"a\" : \"2\", \"b\" : \"4\", \"c\" : \"5\" }  } }');\n")
	@test eq(to_js_value(stdtest, df, ["a", "b"],"var test"), "var test = JSON.parse('{ \"1\" : {\"3\" : {\"a\" : \"1\", \"b\" : \"3\", \"c\" : \"4\" }  }, \"2\" : {\"4\" : {\"a\" : \"2\", \"b\" : \"4\", \"c\" : \"5\" }  } }');\n")
	@test eq(to_js_value(stdtest, df, ["a", "b"],"export const test"), "export const test = JSON.parse('{ \"1\" : {\"3\" : {\"a\" : \"1\", \"b\" : \"3\", \"c\" : \"4\" }  }, \"2\" : {\"4\" : {\"a\" : \"2\", \"b\" : \"4\", \"c\" : \"5\" }  } }');\n")
    @test sum_columns(df) == DataFrame([[3],[7],[9]],["as","bs","cs"])
    @test sum_columns(ddf, group_by=["a"]) == DataFrame([[1,2], [3,6], [4,8]], ["a", "bs", "cs"])
    @test sum_columns(ddf, group_by=["a"], replace_with="X") == DataFrame([[1,2], [3,6], [4,8]], ["a", "bX", "cX"])
    @test group_data_into_periods(dt, :d, "Week") == DataFrame([["1999-52", "2000-05", "2000-09", "2001-01", "2001-05", "2001-09", "2001-48", "2001-26", "2002-01", "2002-05", "2002-09"],[1,1,1,2,1,1,1,1,1,1,1],[2,2,2,4,2,2,2,2,2,2,2]], ["ds", "bs", "cs"])
    @test group_data_into_periods(dt, :d, "Month") == DataFrame([["2000-01", "2000-02", "2000-03", "2001-01", "2001-02", "2001-03", "2001-12", "2001-07", "2002-01", "2002-02", "2002-03"],[1,1,1,1,1,1,2,1,1,1,1],[2,2,2,2,2,2,4,2,2,2,2]], ["ds", "bs", "cs"])
    @test group_data_into_periods(dt, "d", :Quarter) == DataFrame([["2000Q1","2001Q1","2001Q4","2001Q3","2002Q1"], [3,3,2,1,3], [6,6,4,2,6]], ["ds", "bs", "cs"])
    @test group_data_into_periods(dt, :d, :Year) == DataFrame([[2000,2001,2002], [3,6,3], [6,12,6]], ["ds", "bs", "cs"])
    @test match_row(dt, :d, Date(2001,3,1)) == DataFrame([[Date(2001,3,1)], [1], [2]], ["d", "b", "c"])
    @test include_or_exclude(df, includes="a") == DataFrame([[1,2]], ["a"])
    @test include_or_exclude(df, includes=[:a]) == DataFrame([[1,2]], ["a"])
    @test include_or_exclude(df, excludes=[:b, :c]) == DataFrame([[1,2]], ["a"])
    @test include_or_exclude(df, excludes=["a", "b", "c"], includes=:a) == DataFrame([[1,2]], ["a"])
	@test de_miss_rows(DataFrame([[1,missing,3], [10,20,30]], ["a", "b"])) == DataFrame([[1,3], [10,30]], ["a", "b"])
    @test to_csv_text(df) == "a,b,c\n1,3,4\n2,4,5\n"
    @test from_csv_text("a,b,c\n1,3,4\n2,4,5\n") == df
    @test from_csv_text(to_csv_text(dt)) == dt
	@test leftjoiner(dfab, :a, dfac, dfad) == dfabcd
	@test concat!(DataFrame(), df, DataFrame([[2],[2],[3]], ["a", "b", "c"])) == ddf
    @test tryRename(dfab, [:b=>:c]) == dfac
    @test tryRename(dfab, "b"=>"c") == dfac
    @test tryRename(df, [:a=>:q, :b=>:z, :Not=>:Present]) == DataFrame([[1,2],[3,4],[4,5]],["q", "z", "c"])
    @test dropByName!(dfab, n->n=="a") == DataFrame([[4,5,6]], ["b"])
    @test to_csv_text(colsToGrid(DataFrame([["a", "b", "c"], ["d", "e", "f"], [1,2,3], [4,5,6]], ["c1", "c2", "c3", "v"]), :c1, :c2, :v, "see")) == "see,d,e,f\na,4,,\nb,,5,\nc,,,6\n"
end
