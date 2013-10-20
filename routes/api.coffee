db = require '../models/db'
S = require 'string'

exports.hospitals = (req, res) ->

  op_slug = req.params.operations
  conn = db.getConn()

  order = req.query.order || 'price'

  query = [
    'START op=node:INDEX_NAME(INDEX_KEY="INDEX_VAL")',
    'MATCH (hospital) -[rel:FOLLOWS_REL]- (op)',
    'RETURN hospital, rel, op'
  ].join('\n')
  .replace('INDEX_NAME', db.OPERATION_SLUG())
  .replace('INDEX_KEY', 'slug')
  .replace('INDEX_VAL', op_slug)
  .replace('FOLLOWS_REL', db.CHARGES)

  query = [
    query,
    'ORDER BY hospital.rating DESC'
  ].join('\n') if order == 'rating'

  query = [
    query,
    'ORDER BY rel.avg_total_payment'
  ].join('\n') if order == 'price'

  conn.query(query, {}, (err, data2) ->
    throw err if (err)

    output = []

    for hospital_op in data2
      hospital_data = hospital_op.hospital._data.data
      relationship_data = hospital_op.rel._data.data
      operation = hospital_op.op._data.data

      temp =
        name: S(hospital_data.name).capitalize().s
        slug: hospital_data.slug
        operation: S(operation.name).capitalize().s
        price: relationship_data.avg_total_payment
        street: hospital_data.street
        city: hospital_data.city
        zip: hospital_data.zip
        state: hospital_data.state
        rating: hospital_data.rating

      output.push(temp)

    res.json output

  )

exports.operations = (req, res) ->
  conn = db.getConn()

  query = [
    'START op=node:data_type(type="operation")',
    'RETURN op'
  ].join('\n')

  conn.query(query, {}, (err, data2) ->
    throw err if (err)

    output = []

    for _p in data2
      temp_name = _p.op._data.data
      output.push(temp_name)

    res.json output

  )

