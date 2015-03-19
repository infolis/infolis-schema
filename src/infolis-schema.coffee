### 
# Infolis Schema

###

Async          = require 'async'
Merge          = require 'deepmerge'
Mongoose       = require 'mongoose'
MongooseJSONLD = require 'mongoose-jsonld/src'
TSON           = require 'tson/src'
JsonLD2RDF     = require 'jsonld-rapper'

_readNamespaces = (schemology) ->
	return schemology['@ns']

_readOntology = (schemology, ns) ->
	self = @
	ontology = {}
	ontology['@context'] = ns
	ontology['@graph'] = []
	# The onology itself
	ontology['@graph'].push schemology['@context']

	_classes = {}
	_properties = {}

	for clazzName, clazzDef of schemology
		continue if clazzName.indexOf('@') == 0
		_classes[clazzName] = clazzDef['@context'] or {}
		_classes[clazzName]['@id'] or= ns['infolis'] + clazzName
		for propName, propDef of clazzDef
			continue if propName.indexOf('@') == 0
			_properties[propName] or= {}
			propDef['@context'] or= {}
			if typeof propDef['@context'] is 'object'
				_properties[propName] = Merge(_properties[propName], propDef['@context'])
			else 
				console.log 'UNHANDLED @context being a string'
				null # TODO handle string context

			_properties[propName]['@id'] or= ns['infolis'] + propName

			_properties[propName]['schema:domainIncludes'] or= []
			_properties[propName]['schema:domainIncludes'].push {'@id': _classes[clazzName]['@id']}

		ontology['@graph'].push(prop) for propName, prop of _properties
	ontology['@graph'].push(clazz) for clazzName, clazz of _classes
	return ontology

 # TODO
_validators = {
	'validateURI': [
		(val) ->
			return true
		, "Not a valid URI"
	]
	'validateMD5': [
		(val) ->
			return true
		, "Not a valid MD5"
	]
}

_typeMap = {
	'String': String
	'Number': Number
	'ObjectId': Mongoose.Schema.ObjectId
	'Date': Date
}
_readSchemas = (schemology, mongooseJSONLD, dbConnection) ->
	ret = {
		model: {}
		schema: {}
	}
	for schemaName, schemaDef of schemology
		continue if schemaName.indexOf('@') == 0
		schemaDef = JSON.parse JSON.stringify schemaDef
		contexts = []
		schemaContext = schemaDef['@context']
		schemaContext['rdf:type'] = 'rdfs:Class'
		contexts.push schemaContext
		delete schemaDef['@context']
		# XXX
		# delete ctx['@id']
		for propName, propDef of schemaDef

			# handle validate functions
			if propDef['validate']
				validate = _validators[propDef['validate']]
				if not validate
					throw new Error("No function handling #{propDef['validate']}")
				else
					propDef['validate'] = validate 

			# handle dbrefs
			if propDef['type'] and Array.isArray(propDef['type'])
				typeDef = propDef['type'][0]
				typeDef['type'] = _typeMap[typeDef['type']]

			# handling flat types
			else if propDef['type']
				propDef['type'] = _typeMap[propDef['type']]

			if typeof propDef['@context'] is 'object'
				propContext = propDef['@context']
				propContext['rdf:type'] = 'rdfs:Property'
				propContext['schema:domainIncludes'] or= []
				propContext['schema:domainIncludes'].push {'@id': schemaContext['@id']}
				contexts.push propContext
			else 
				console.log 'UNHANDLED @context being a string'
				null # TODO handle string context

		thisSchema = new Mongoose.Schema(schemaDef, {'@context': contexts})
		thisSchema.plugin(mongooseJSONLD.createMongoosePlugin())
		# console.log thisSchema.paths?.creator?.options
		# console.log thisSchema instanceof Mongoose.Schema
		thisModel = dbConnection.model(schemaName, thisSchema)
		ret.schema[schemaName] = thisSchema
		ret.model[schemaName] = thisModel
	return ret

class InfolisSchemas

	constructor : (opts) ->
		opts or= {}
		opts.pathToSchemology or= __dirname + '/../data/infolis.tson' 
		opts.dbConnection or= Mongoose.connection
		@schemology = TSON.load opts.pathToSchemology
		if @schemology instanceof Error
			throw @schemology
		@ns = _readNamespaces(@schemology)
		if opts.baseURI
			@ns['infolis'] = opts.baseURI
		@j2r = new JsonLD2RDF(
			baseURI: @ns['infolis']
			expandContext: @ns
		)
		@ontology = _readOntology(@schemology, @ns)
		@mongooseJSONLD = new MongooseJSONLD(
			baseURL: 'http://www-test.bib-uni-mannheim.de/infolis'
			apiPrefix: '/api'
			expandContext: 'basic'
		)
		# console.log @dbConnection.model
		@mongoose = _readSchemas(@schemology, @mongooseJSONLD, opts.dbConnection)


	getOntology : (format, cb) ->
		if typeof format is 'function' then [cb, format] = [format, 'jsonld']
		throw new Error("Must provide cb") unless cb

		format or= 'jsonld'

		return @j2r.convert @ontology, 'jsonld', format, (err, data) ->
			cb err if err
			cb null, data



module.exports = InfolisSchemas


# ALT: test/test.coffee
