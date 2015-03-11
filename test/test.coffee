test = require 'tapes'
Async = require 'async'
TSON = require 'tson/src/'

testFunc = (t) ->
	x = TSON.load 'src/infolis.tson'
	console.log x
	t.end()
	# Async.each [0,0,0], (number, cb) ->
	#
	#     t.equals number, 0, 'Number is zero'
	#     cb()
	# , () -> t.end()

test "Basic async each test", testFunc

# ALT: src/index.coffee
