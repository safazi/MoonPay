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

indexOf = (Table, Value) -> return I for I, V in pairs Table when V == Value

class Chance
	@uniqueMaxAttempts: 100
	new: (Seed) => @reseed Seed
	-- Primitive
	bool: => 1 == @number 0, 1

	-- Number
	number: (A, B) => -- Lower (or table), Upper
		AN = tonumber A
		BN = tonumber B
		return AN if AN == BN
		if AN > BN
			temp = AN
			BN = AN
			AN = temp
		return math.random AN, BN if AN and BN
		assert 'table' == type(A), 'invalid parameter object passed to Chance.number'
		@number A.lower, A.upper

	-- String
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
			result ..=  switch char
				when 'X' -- upper
					@char 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
				when '*' -- charset
					@char!
				when 'N' -- number
					@number 0,9
				when 'A' -- upper and lower
					@char 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
				else char
		result

	-- Time
	month: =>
		@pickone {'January', 'Feburary', 'March', 'April',
			'May', 'June', 'July', 'August',
			'September', 'October', 'November', 'December'}
	day: =>
		@pickone {'Monday', 'Tuesday', 'Wednesday', 'Thursday',
			'Friday', 'Saturday', 'Sunday'}
	ampm: => ({'am', 'pm'})[@number 1, 2]
	hour: (Params = {}) =>
		default Params, 'twentyfour', false
		@number 1, Params.twentyfour and 24 or 12
	minute: => @number 0, 59
	second: => @number 0, 59
	millisecond: => @number 0, 999

	-- Util
	coin: => ({'heads', 'tails'})[@number 1, 2]
	dice: (max = 6) => @number 1, max
	rpg: (str, Params = {}) =>
		default Params, 'sum', false
		num, max = str\match '(%d+)d(%d+)'
		assert num and max, 'invalid string passed to Chance.rpg'
		assert tonumber(max) > 1, 'invalid max passed to Chance.rpg'
		result = @n @dice, num, max
		return result if not Params.sum
		total = 0
		total += n for n in *result
		total
	pad: (str, len, char = 0) =>
		s = tostring char
		while #str < len
			str = s .. char
		str
	prefix: (str, F, ...) =>
		tostring(str) .. switch type F
			when 'function'
				F @, ...
			else tostring F
	capitalize: (str) => str\sub(1,1)\upper! .. str\sub 2
	pickone: (array) =>
		assert 'table' == type(array), 'invalid list passed to Chance.pickone'
		len = #array
		return if len == 0
		return array[1] if len == 1 
		array[@number 1, len]
	pickset: (array, quantity = 1) =>
		assert 'table' == type(array), 'invalid list passed to Chance.pickset'
		[@pickone array for i=1,quantity]
	unique: (F, N, ...) =>
		result = {}
		for i=1,N
			val = F @, ...
			z = 0
			while indexOf result, val
				val = F @, ...
				z += 1
				break if z > @@uniqueMaxAttempts
			table.insert result, val
		result 
	n: (F, N, ...) => [F @, ... for i=1,N]
	shuffle: (array) =>
		assert 'table' == type(array), 'invalid list passed to Chance.shuffle'
		clone = [v for v in *array]
		for i=#clone,1,-1 do
			r = @number 1, i
			n = clone[r]
			clone[r] = clone[i]
			clone[i] = n
		clone
	reseed: (Seed = 0) =>
		assert 'number' == type(Seed), 'invalid seed number passed to Chance.reseed)'
		math.randomseed Seed