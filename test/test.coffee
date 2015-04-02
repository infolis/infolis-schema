test           = require 'tapes'
InfolisSchemas = require '../src/infolis-schema'
Mongoose       = require 'mongoose'

dbConnection = Mongoose.createConnection('mongodb://localhost:27018/test')

infolisSchemas = new InfolisSchemas(
	pathToSchemology: __dirname + '/../data/infolis.tson',
	dbConnection: dbConnection)
{ Publication, Algorithm, Person } = infolisSchemas.models

testFunc = (t) ->
	END = -> dbConnection.close();t.end()
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
			console.log algo.jsonldABox()
			END()

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
test "Ontology turtle", (t) ->
	infolisSchemas.models.Algorithm.jsonldTBox {to: 'turtle'}, (err, data) ->
		console.log data
	# infolisSchemas.jsonldTBox {'to': 'turtle'}, (err, data) ->
		# console.log data
# test "Basic test", testFunc2
# test "Basic test", testFunc3

# ALT: src/index.coffee
