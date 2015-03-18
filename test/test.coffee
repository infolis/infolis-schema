test           = require 'tapes'
InfolisSchemas = require '../src'
Mongoose       = require 'mongoose'

dbConnection = Mongoose.createConnection('mongodb://localhost:27018/test')

infolisSchemas = new InfolisSchemas(__dirname + '/../data/infolis.tson', dbConnection)
{ Publication, Algorithm, Person } = infolisSchemas.mongoose.model

testFunc = (t) ->

	infolisSchemas.getOntology 'turtle', (err, data) ->
		# console.log data
		person = new Person {
			given: 'John'
			surname: 'Doe'
		}
		person.save (err) ->
			algo = new Algorithm {
				name:'bla'
				creator: person._id
			}
			algo.save (err, saved) ->
				console.log err
				console.log saved
				return t.end()

# testFunc2 = (t) ->
#     algo = Algorithm.create {
#         name: 'foo'
#         creator: {
#             given: 'Jane'
#             surname: 'Doe'
#         }
#     }
#     algo.save (err) ->
#         console.log err 
#         t.end()
#
#

test "Basic test", testFunc
# test "Basic test", testFunc2
# test "Basic test", testFunc3

# ALT: src/index.coffee
