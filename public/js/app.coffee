angular.module 'app.controllers', []

angular.module('app', [
  'ngRoute',
  "ui.map",
  "ui.event",
  'restangular',
  'app.controllers'
]).config ($routeProvider, $locationProvider, RestangularProvider) ->
  $routeProvider.when '/',
    templateUrl: 'templates/home.html',
    controller: 'HomeCtrl'
  .when '/search/:operation',
    templateUrl: 'templates/search.html',
    controller: 'SearchCtrl'
  .when '/search/:operation/:order',
    templateUrl: 'templates/search.html',
    controller: 'SearchCtrl'
  .otherwise
    redirectTo: '/'

  RestangularProvider.setBaseUrl('/api/');

#  $locationProvider.html5Mode(true)
