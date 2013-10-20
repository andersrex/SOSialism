neo4j = require 'neo4j'

exports.getConn = ->
  conn = new neo4j.GraphDatabase(process.env.NEO4J_URL || 'http://localhost:7474')
  conn

exports.HOSPITAL_SLUG_INDEX = ->
  'hospital_slug'

exports.OPERATION_SLUG = ->
  'operation_slug'

exports.PRICES_VALUE = ->
  'prce_value'

exports.CHARGES = ->
  'charges'

exports.TYPE_INDEX = ->
  'data_type'
