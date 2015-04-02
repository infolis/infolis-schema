### 
# Infolis Schema

###

Async          = require 'async'
Merge          = require 'deepmerge'
Mongoose       = require 'mongoose'
MongooseJSONLD = require 'mongoose-jsonld'
TSON           = require 'tson'
JsonLD2RDF     = require 'jsonld-rapper'

class InfolisSchemas

	constructor : (opts) ->
		opts or= {}
		@[k] = v for k,v of opts
		@pathToSchemology or= __dirname + '/../data/infolis.tson' 
		@schemology = TSON.load @pathToSchemology
		@ns = @schemology['@ns'] or {}
		if @schemology instanceof Error
			throw @schemology

		if not @dbConnection
			throw new Error("Need a DB Connection, provide 'dbConnection' to constructor")

		@mongooseJSONLD = new MongooseJSONLD(
			baseURI: 'http://www-test.bib.uni-mannheim.de/infolis'
			apiPrefix: '/api'
			schemaPrefix: '/schema'
			expandContexts: ['basic', @ns]
		)

		@schemas = {}
		@models = {}
		@onto = {
			'@context': {}
			'@graph': []
		}

		@_readSchemas()
		# @ontology = _readOntology(@schemology, @ns)
		# console.log @dbConnection.model

	_readSchemas : () ->
		for schemaName, schemaDef of @schemology
			if schemaName is '@ns'
				@onto['@context'][ns] = uri for ns,uri of schemaDef
			else if schemaName is '@context'
				# TODO add id
				@onto['@graph'].push schemaDef
			else
				schemaDef = JSON.parse JSON.stringify schemaDef
				# console.log schemaName
				# console.log schemaDef
				@schemas[schemaName] = @mongooseJSONLD.createSchema(schemaName, schemaDef)
				@models[schemaName] = @dbConnection.model(schemaName, @schemas[schemaName])
				@onto['@graph'].push @models[schemaName].jsonldTBox()

	jsonldTBox : (opts, cb) ->
		if typeof opts == 'function' then [cb, opts] = [opts, {}]
		if cb
			return @mongooseJSONLD._convert(@onto, opts, cb)
		else
			return @onto

module.exports = InfolisSchemas


# ALT: test/test.coffee
