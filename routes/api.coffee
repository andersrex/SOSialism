exports.hospitals = (req, res) ->

  console.log req.params.operation

  res.json [
    {
      name: "Hospital Blablabla"
      street: "165 Jessie st", city: "San Francisco", zip: "94105", state: "CA"
      operation: "Knee surgery"
      price: 250
      rating: 4.5
    },
    {
      name: "Hospital LILILI"
      street: "1008 Capp st", city: "San Francisco", zip: "94105", state: "CA"
      operation: "Knee surgery"
      price: 200
      rating: 4
    }
  ]

exports.operations = (req, res) ->

  res.json [
    {
      name: "Knee operation",
      slug: "knee_operation"
    },
    {
      name: "Flu shot",
      slug: "flu_shot"
    },
    {
      name: "Brain surgery",
      slug: "brain_surgery"
    }
  ]


