controllers = angular.module 'app.controllers', []

controllers.controller "MainCtrl", ["$scope", ($scope) ->
]

controllers.controller "HomeCtrl", ["$scope", ($scope) ->
  console.log "HomeCtrl"
]

controllers.controller "SearchCtrl", ["$scope", ($scope) ->
  console.log "SearchCtrl"
  $scope.markers = []

  $scope.results = [
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
  },

  ]

  $scope.mapOptions =
    backgroundColor: "#edeae3"
    center: new google.maps.LatLng(37.7884460, -122.4004104)
    zoom: 13
    mapTypeId: google.maps.MapTypeId.ROADMAP
    streetViewControl: false
    panControl: false
    rotateControl: false
    zoomControl: true
    mapTypeControl: false
    zoomControlOptions:
      style: google.maps.ZoomControlStyle.SMALL
      overviewMapControl: false
      mapTypeControl: false
      position: google.maps.ControlPosition.RIGHT_TOP

  $scope.onMapIdle = ->
  $scope.onMapReady = ->
  $scope.markerClicked = ->

]


