local lpeg = require "lpeg"
local re = require "re"

local gram = re.compile[=[
	gram <- {| lines {:_trailing: {.*} :} |} 
	lines <- line*
	line <- {| keyvalue |} %nl*
	varname <- [a-zA-Z_] [_a-zA-Z0-9]*
	value <- string
	keyvalue <- {:varname: {varname} :} anyspace '=' anyspace anyvalue
	anyvalue <- ( stringvalue / tablevalue ) %nl?
	stringvalue <- {:value: string :}
	string <- string1 / string2 / string3
	string1 <- {| '"' { [^"]* } '"' {:_type: '' -> "string1" :} |}
	string2 <- {| "'" { [^']* } "'" {:_type: '' -> "string2" :} |}
	string3 <- {| {:_type: '' -> "string3" :} "[[" %nl? { [^]]* } "]]" |}
	tablevalue <-  {:value: table :}
	table <- {| {:_type: '' -> "table" :} "{" %nl? anyspace ( tableitem ("," %nl? anyspace tableitem )* ) / ( tableitem ",") "}" |}
	tableitem <- tablekeyvalue / tablequickvalue
	tablequickvalue <- {| stringvalue |}
	tablekeyvalue <- {| ( {:tkey: anytablekeys :} anyspace "=" anyspace {:tvalue: anyvalue :} anyspace) |}
	anytablekeys <- {| ("[" anyspace ( string1 / string2 ) anyspace "]") / { varname } {:_type: '' -> "likevarname" :} |}
	anyspace <- (' ' )*
	somespaces <- (' ' / %nl )+

	name <- [^ <>()=,]+
]=]

local function parse(data)
	return gram:match(data)
end

local data
--data = [[package = "luafilesystem"]]
--data = [[package = 'luafilesystem']]
--data = "package = [[luafilesystem]]"

data = [[
package = "luafilesystem"
version = "scm-1"
source = {
   url = "git://github.com/keplerproject/luafilesystem"
}
]]

data = [=[
package = "luafilesystem"
version = "scm-1"
foo = 'F o o'
bar = [[
    BAR
    blah blah
]]
tab1 = {
 ["foo"] = "FOO",
   bar = "BAR"
}
]=]

data = [=[
build = {
   type = "builtin",
   modules = {
      lfs = "src/lfs.c"
   },
   copy_directories = {
      "doc",
      "tests"
   }
}
]=]

local result = parse(data)

local tprint = require"tprint"
print(tprint(result, {inline=false}))
