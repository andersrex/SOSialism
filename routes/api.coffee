exports.hospitals = (req, res) ->
  res.json [
    {
      name: "Hospital Blablabla"
      location: ""
      street: "165 Jessie st", city: "San Francisco", zip: "94105", state: "CA"
      operation: "Knee surgery"
      price: 250
      ratings: 5
    },
    {
      name: "Hospital LILILI"
      location: ""
      street: "165 Jessie st", city: "San Francisco", zip: "94105", state: "CA"
      operation: "Knee surgery"
      price: 200
      ratings: 4
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


