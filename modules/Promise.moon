-- Promise.moon
-- SFZILabs 2019

isCallable = (O) ->
	return true if 'function' == type O
	MT = getmetatable O
	return 'function' == type MT.__call if 'table' == type MT

class
	@State: PENDING: 0, FULFILLED: 1, REJECTED: 2
	@Async: (F) -> coroutine.wrap(F)!
	@Queue: {}
	new: (Callback) =>
		@State = @@State.PENDING
		@Queue = {}
		@IsPromise = true
		Callback @\Resolve, @\Reject if Callback

	Transition: (State, Value) =>
		if @State == State or -- Don't overwrite value
			@State ~= @@State.PENDING or -- Don't change state
			Value == nil or -- Don't accept no value/reason
			(State ~= @@State.FULFILLED and State ~= @@State.REJECTED) -- Only accept one of two states
				return
		@State = State
		@Value = Value
		@Update!

	Reject: (Reason) => @Transition @@State.REJECTED, Reason
	Fulfill: (Value) => @Transition @@State.FULFILLED, Value

	Update: =>
		return if @State == @@State.PENDING
		F = @@Async or (V) -> table.insert @@Queue, V
		F ->
			I = 0
			while I < #@Queue
				I += 1
				Operation = @Queue[I]
				Success, Result = pcall ->
					Success = Operation.Resolved or (x) -> x
					Failure = Operation.Rejected or (x) -> error x
					Callback = @State == @@State.FULFILLED and Success or Failure
					return Callback @Value
				if Success
					@Resolve Result
				else @Reject Result
			@Queue[J] = nil for J = 1, I

	Process: ->
		while true
			Operation = table.remove Promise.Queue, 1
			break if not Operation
			Operation!

	Resolve: (Value) =>
		if @ == Value
			return @Reject 'TypeError: Cannot resolve a promise with itself'
		if 'table' ~= type Value
			return @Fulfill Value
		if Value.IsPromise
			if Value.State == @@State.PENDING
				return Value\next @\Resolve, @\Reject
			return @Transitition Value.State, Value.Value
		return @Fulfill Value
		-- -- Uncomment for other implementations of promise
		-- Called = false
		-- Success, Result = pcall ->
		-- 	if isCallable Value.next
		-- 		Resolve = (Value) ->
		-- 			return if Called
		-- 			@Resolve Value
		-- 			Called = true
		-- 		Reject = (Reason) ->
		-- 			return if Called
		-- 			@Reject Reason
		-- 			Called = true
		-- 		Value\next Resolve, Reject
		-- 	else @Fulfill Value
		-- @Reject Result if not Success and not Called
	
	next: (Resolved, Rejected) =>
		Next = @@!
		table.insert @Queue, with {}
			.Resolved = Resolved if isCallable Resolved
			.Rejected = Rejected if isCallable Rejected
			.Promise = Next
		@Update!
		Next

	catch: (Callback) => @next nil, Callback
	all: (...) ->
		Promises = {...}
		Results = {}
		State = Promise.State.FULFILLED
		Remaining = #Promises
		Next = Promise!
		Check = ->
			return if Remaining > 0
			Promise.Transition Next, State, Results
		for I, P in pairs Promises
			Resolved = (Value) ->
				Results[I] = Value
				Remaining -= 1
				Check!
			Rejected = (Reason) ->
				Results[I] = Value
				Remaining -= 1
				State = Promise.State.REJECTED
				Check!
			P\next Resolved, Rejected
		Check!
		Next

	race: (...) ->
		Promises = {...}
		Next = Promise!
		Promise.all(...)\next nil, (V) -> Promise.Reject Next, V
		Success = (V) -> Promise.Fulfill Next, V
		P\next Success for P in *Promises
		Next