-- Job.moon

EventEmitter = require 'eventemitter'

GUID = ->
    template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    string.gsub template, '[xy]', (c) ->
        v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        string.format '%x', v

class Job extends EventEmitter
	new: (@ID = GUID!) =>
	progress: (Value, Max) => @emit 'progress', Value/Max, Value, Max
	resolve: (@Result) => @emit 'status', 1, @Result
	fail: (@Failure) => @emit 'status', -1, @Failure