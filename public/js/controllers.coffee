controllers = angular.module 'app.controllers', []

controllers.controller "MainCtrl", ["$scope", ($scope) ->
]

controllers.controller "HomeCtrl", ["$scope", "Restangular", ($scope, Restangular) ->

  Restangular.one('operations').getList().then (operations) ->
    console.log operations
    $scope.operations = operations

]

controllers.controller "SearchCtrl", ["$scope","$routeParams", "Restangular", ($scope, $routeParams, Restangular) ->
  $scope.markers = []

  Restangular.one('operations').getList().then (operations) ->
    $scope.operations = operations

  if $routeParams.operation
    Restangular.one('hospitals').getList().then (results) ->
      console.log "Got results!"
      $scope.results = results

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


