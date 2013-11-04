angular.module('app.controllers').controller "MainCtrl",
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