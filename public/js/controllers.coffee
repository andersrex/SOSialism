controllers = angular.module 'app.controllers', []

controllers.controller "MainCtrl",
["$scope", "Restangular", "$window", "$location", "$rootScope", "geocoder", "$timeout",
($scope, Restangular, $window, $location, $rootScope, geocoder, $timeout) ->
  $scope.pin = new google.maps.MarkerImage("/images/pin.png", null, null, null, new google.maps.Size(35,35))
  $scope.markers = []
  $scope.mapOptions =
    backgroundColor: "#edeae3"
    center: new google.maps.LatLng(37.780015, -122.446937)
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

  Restangular.one('operations').getList().then (operations) ->
    $scope.operations = operations

  $scope.$watch "selection", ->
    if $scope.selection
      $location.path("/search/#{$scope.selection}")

  $scope.$on '$locationChangeSuccess', (event) ->
    $scope.selection = $window.location.hash.split("/")[2]
    $rootScope.page = $scope.page = $window.location.hash.split("/")[1]
    console.log "$locationChangeSuccess", $scope.selection

  # Markers should be added after map is loaded
  $scope.onMapReady = =>
    $rootScope.$watch "results", ->
      results = $rootScope.results

      if results and results.length and not $scope.mapLoaded
        $scope.mapLoaded = true

        for m in $scope.markers
          m.setMap(null)
        $scope.markers = []

        for result in results
          geocoder.geocode("#{result.street}, #{result.city}").then (location) ->
            result.lat = location.lat()
            result.lng = location.lng()
            $scope.addMarker(result)
    , true

  $scope.markerClicked = (m) ->
    $scope.map.panTo(m.position)
    console.log "panTo", m.position.lat(), m.position.lng()
    m.setAnimation(google.maps.Animation.BOUNCE)

    $timeout ->
      m.setAnimation(null)
    , 1440

  $rootScope.clickMarker = (index) ->
    $scope.markerClicked($scope.markers[index])

  $scope.addMarker = (result) ->
    console.log "Adding marker to", result.lng, result.lng
    marker = new google.maps.Marker
      map: $scope.map
      position: new google.maps.LatLng(result.lat, result.lng)
      icon: $scope.pin
      animation: google.maps.Animation.DROP

    $scope.markers.push marker
]

controllers.controller "HomeCtrl", ["$scope", "Restangular", "$location", ($scope, Restangular, $location) ->

  $scope.search = ->
    $location.path("/search/#{$scope.selection}") if $scope.selection


#  Restangular.one('operations').getList().then (operations) ->
#    console.log operations
#    $scope.operations = operations

]

controllers.controller "SearchCtrl",
["$scope","$routeParams", "Restangular", "geocoder", "$rootScope",
($scope, $routeParams, Restangular, geocoder, $rootScope) ->

  if $routeParams.operation
    Restangular.one('hospitals', $routeParams.operation).getList().then (results) ->
      $rootScope.results = $scope.results = results

  $scope.selectResult = (result, index) ->
    $scope.selectedResult = result
    $rootScope.clickMarker(index)
    console.log "Selecting #{index}"




