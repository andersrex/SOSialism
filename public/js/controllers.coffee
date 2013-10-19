controllers = angular.module 'app.controllers', []

controllers.controller "MainCtrl",
["$scope", "Restangular", "$window", "$location", "$rootScope",
($scope, Restangular, $window, $location, $rootScope) ->
  Restangular.one('operations').getList().then (operations) ->
    $scope.operations = operations

  $scope.$watch "selection", ->
    if $scope.selection
      $location.path("/search/#{$scope.selection}")

  $scope.$on '$locationChangeSuccess', (event) ->
    $scope.selection = $window.location.hash.split("/")[2]
    $rootScope.page = $scope.page = $window.location.hash.split("/")[1]
    console.log "$locationChangeSuccess", $scope.selection
]

controllers.controller "HomeCtrl", ["$scope", "Restangular", "$location", ($scope, Restangular, $location) ->

  $scope.search = ->
    $location.path("/search/#{$scope.selection}")

#  Restangular.one('operations').getList().then (operations) ->
#    console.log operations
#    $scope.operations = operations

]

controllers.controller "SearchCtrl", ["$scope","$routeParams", "Restangular", ($scope, $routeParams, Restangular) ->
  $scope.markers = []

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


