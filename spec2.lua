local lpeg = require "lpeg"
local re = require "re"

local gram = re.compile[=[
	gram <- {| lines {:_trailing: {.*} :} |} 
	lines <- line*
	line <- {| keyvalue |} %nl*
	varname <- [a-zA-Z] [_a-zA-Z0-9]*
	value <- string
	keyvalue <- {:varname: {varname} :} anyspace '=' anyspace anyvalue
	anyvalue <- stringvalue / table
	stringvalue <- {:value: string :}
	string <- string1 / string2 / string3
	string1 <- {| '"' { [^"]* } '"' {:_type: '' -> "string1" :} |}
	string2 <- {| "'" { [^']* } "'" {:_type: '' -> "string2" :} |}
	string3 <- {| "[[" %nl { [^]]* } "]]" %nl {:_type: '' -> "string3" :} |}
	table <- {| "{" anyspace tablekeyvalue "}" {:_type: '' -> "table" :} |}
	tablekeyvalue <- {| ( {:tkey: anytablekeys :} anyspace "=" anyspace {:tvalue: anyvalue :} anyspace) |}
	anytablekeys <- {| ("[" anyspace ( string1 / string2 ) anyspace "]") / { varname } |}
	anyspace <- (' '/ %nl )*

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
 ["foo"] = "FOO"
}
tab2 = {
   bar = "BAR"
}
]=]

local result = parse(data)

local tprint = require"tprint"
print(tprint(result, {inline=false}))
