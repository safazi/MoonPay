-- Database.moon
-- SFZILabs 2019

class File
	new: (@Path) =>
		@Load!
		@Touch! if @Content == '' or not @Content 
	Load: => error 'File.Load: Not implemented' -- Set @Content after reading @Path, set @Empty if empty
	Write: (Content) => error 'File.Write: Not implemented' -- Write Content to @Path
	Touch: => error 'File.Touch: Not implemented' -- Create file @Path

class SerializedFile extends File
	Deserialize: (Content) => error 'SerializedFile.Deserialize: Not implemented' -- Return Content deserialized
	Serialize: (Content) => error 'SerializedFile.Serialize: Not implemented' -- Return Content serialized
	new: (...) =>
		super ...
	Load: => -- set @Empty if empty
		super!
		@Content = @Deserialize @Content
	Write: (Content) => super @Serialize Content

class Entry
	new: (@Value, @Root) =>
	value: => @Value
	get: (Key) =>
		return if 'table' ~= type @Value
		@@ @Value[Key], @Root
	unset: (Key) => @set Key
	set: (Key, Value) =>
		return if 'table' ~= type @Value 
		@Value[Key] = Value
		@
	isArray: =>
		return false if 'table' ~= type @Value 
		#[1 for _,_ in pairs @Value] == #@Value
	isObject: =>
		return false if 'table' ~= type @Value 
		not @isArray!
	find: (Props = {}) =>
		return if 'table' ~= type @Value 
		Result = {}
		Object = @isObject!
		for K, V in pairs @Value
			continue if 'table' ~= type V
			continue if (@@ V)\isArray!
			Add = true
			for L, B in pairs Props
				if B ~= V[L]
					Add = false
					break
			if Add
				if Object
					Result[K] = V
				else table.insert Result, V
		Result
	push: (...)=>
		return if not @isArray!
		A = {...}
		return if #A <= 0
		table.insert @Value, V for V in *A
		@
	indexOf: (V) =>
		return if not @isArray!
		return if V == nil
		return I for I, O in pairs @Value when O == V
	pluck: (V) =>
		return if not @isArray!
		return table.remove I for I, O in pairs @Value when O == V
	write: => @Root\write!

class Database extends Entry
	new: (@FileAdapter) =>
		@Root = @
		@Adapter\Load!
		with @Adapter
			@Value = .Content
			.Content = nil
	write: => @Adapter\Write @Value
	default: (T) =>
		@Value = T if @Adapter.Empty
		@

:File, :SerializedFile, :Database