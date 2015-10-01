# Chai = require 'chai'
# Chai.should()
should = require 'should'
# Assert   = require 'assert'
# Mongoose = require 'mongoose'

InfolisSchemas = require '../src/infolis-schema'



dbConnection = null

models = {}

describe 'Algorithm - Person', ->
	before ->
		console.log 'yay'
		dbConnection = Mongoose.createConnection('mongodb://localhost:27018/test')
		infolisSchemas = new InfolisSchemas(
			pathToSchemology: __dirname + '/../data/infolis.tson',
			dbConnection: dbConnection)
		for i in 'Publication Algorithm Person'.split(' ')
			models[i] = infolisSchemas.models[i]
	after ->
		dbConnection.close()
		models = {}
	describe 'person should be saved', ->
		it 'should save without problem', ->
			person = new models.Person {
				given: 'John'
				surname: 'Doe'
			}
			# person._id.should.be.an.instanceof(Mongoose.Types.ObjectId)
			person.save (err) ->
				person._id.should.not.be.ok()
				algo = new Algorithm {
					name:'bla'
					creator: person._id
				}
				algo.save (err, saved) ->
					console.log err
					console.log saved
					console.log algo.jsonldABox()



# testFunc = (t) ->
#     setUp()

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

# test "Basic test", testFunc
# test "Ontology turtle", (t) ->
#     setUp()
#     Algorithm.jsonldTBox {to: 'turtle'}, (err, data) ->
#         console.log data
#         tearDown(t)
	# infolisSchemas.jsonldTBox {'to': 'turtle'}, (err, data) ->
		# console.log data
# test "Basic test", testFunc2
# test "Basic test", testFunc3

# ALT: src/index.coffee
