local lpeg = require "lpeg"
local re = require "re"

local gram = re.compile[[
	gram <- {| {| {:key: {varname} :} anyspace '=' anyspace '"' {:value: {varname} :} '"' |} {.*} |} 
	varname <- [a-zA-Z] [_a-zA-Z0-9]*

	items <- {| item (',' item )* |}
	anyspace <- ' '*
	name <- [^ <>()=,]+
	version <- ([^ %nl,()])+
]]

local parse = function(data)
	return gram:match(data)
end

local data = [[package = "luafilesystem"]]

local result = parse(data)

local tprint = require"tprint"
print(tprint(result, {inline=false}))
