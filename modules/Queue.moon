-- Queue.moon
-- SFZILabs 2019

class
	new: => @List = {}
	push: (...) => table.insert @List, V for V in *{...}
	next: => table.remove @List, 1
	hasNext: => #@List > 0
	unshift: (V) => table.insert V, 1
	isEmpty: => not @hasNext!