controllers = angular.module 'app.controllers', []

controllers.controller "MainCtrl",
["$scope", "Restangular", "$window", "$location", "$rootScope", "$timeout",
($scope, Restangular, $window, $location, $rootScope, $timeout) ->
  $scope.pin = new google.maps.MarkerImage("/images/pin.png", null, null, null, new google.maps.Size(35,35))
  $scope.markers = []
  $scope.mapOptions =
    backgroundColor: "#eeeeee"
    center: new google.maps.LatLng(37.780015, -122.446937)
    zoom: 12
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
      position: google.maps.ControlPosition.RIGHT_BOTTOM

  Restangular.one('operations').getList().then (operations) ->
    $scope.operations = operations

  $scope.$watch "selection", ->
    if $scope.selection
      $location.path("/search/#{$scope.selection}")

  $scope.$on '$locationChangeSuccess', (event) ->
    $scope.selection = $window.location.hash.split("/")[2]
    $rootScope.page = $scope.page = $window.location.hash.split("/")[1]

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
          if result.loc
            result.lat = result.loc[0]
            result.lng = result.loc[1]
            $scope.addMarker(result)
    , true

  $scope.markerClicked = (m) ->
    $scope.map.panTo(m.position)
    m.setAnimation(google.maps.Animation.BOUNCE)

    $rootScope.selectResultByIndex($scope.markers.indexOf(m))

    $timeout ->
      m.setAnimation(null)
    , 1440

  $rootScope.clickMarker = (index) ->
    $scope.markerClicked($scope.markers[index])
    $rootScope.selectResultByIndex(index)

  $scope.addMarker = (result) ->
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
]

controllers.controller "SearchCtrl",
["$scope","$routeParams", "Restangular", "$rootScope", "$location"
($scope, $routeParams, Restangular, $rootScope, $location) ->

  if $routeParams.operation
    if $routeParams.order is "rating"
      $scope.orderByRatings = true

      Restangular.one('hospitals', $routeParams.operation).customGETLIST("", {order: "rating"}).then (results) ->
        $rootScope.results = $scope.results = results
    else
      $scope.orderByRatings = false
      Restangular.one('hospitals', $routeParams.operation).getList().then (results) ->
        $rootScope.results = $scope.results = results

  $scope.selectResult = (result, index) ->
    $scope.selectedResult = result
    $rootScope.clickMarker(index)

  $rootScope.selectResultByIndex = (index) ->
    $scope.selectedResult = $scope.results[index]

  $scope.search = ->
    $scope.orderByRatings = false
    $location.path("/search/#{$routeParams.operation}") if $routeParams.operation

  $scope.searchRatings = ->
    $scope.orderByRatings = true
    $location.path("/search/#{$routeParams.operation}/rating") if $routeParams.operation
]



