angular.module('app.controllers').controller "SearchCtrl",
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



