-- Chance.moon
-- SFZILabs 2019

charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

toCharArray = (Str) ->
	return if 'string' ~= type Str
	[Str\sub i,i for i=1,#Str]

charlist = toCharArray charset

default = (Params, Key, Value) ->
	return if 'table' ~= type Params
	Params[Key] = Value if Params[Key] == nil

class
	new: (Seed) => @reseed Seed
	number: (A, B) => -- Lower (or table), Upper
		return math.random A, B if tonumber(A) and tonumber B
		assert 'table' == type(A), 'invalid parameter object passed to Chance.number'
		math.random A.lower, A.upper
	char: (list = charlist) =>
		list = toCharArray list if 'string' == type list
		assert 'table' == type(list), 'invalid list passed to Chance.char'
		list[@number 1, #list]
	string: (Params = {}) =>
		default Params, 'charset', charset
		default Params, 'length', 16
		list = charlist
		length = #list
		if Params.charset ~= charset
			list = toCharArray Params.charset
		table.concat (@n Params.length, @char, list), ''
	format: (String) =>
		format = toCharArray String
		assert format, 'invalid format string passed to Chance.format'
		result = ''
		for char in *format
			switch char
				when 'X' -- upper
					result ..= @char 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
				when '*' -- charset
					result ..= @char!
				when 'N' -- number
					result ..= @number 0,9
				when 'A' -- upper and lower
					result ..= @char 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
				else
					result ..= char
		result
	n: (N = 1, F, ...) => [F @, ... for i=1,N]
	reseed: (Seed = 0) =>
		assert 'number' == type(Seed), 'invalid seed number passed to Chance.reseed)'
		math.randomseed Seed