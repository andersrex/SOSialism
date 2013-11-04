angular.module('app.controllers').controller "HomeCtrl",
["$scope", "Restangular", "$location",
($scope, Restangular, $location) ->

  $scope.search = ->
    $location.path("/search/#{$scope.selection}") if $scope.selection
]
