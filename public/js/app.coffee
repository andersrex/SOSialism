angular.module('app', [
  'ngRoute',
  "ui.map",
  "ui.event",
  'app.controllers',
  'app.services',
  'restangular'
]).config ($routeProvider, $locationProvider, RestangularProvider) ->
  $routeProvider.when '/',
    templateUrl: 'templates/home.html',
    controller: 'HomeCtrl'
  .when '/search/:operation',
    templateUrl: 'templates/search.html',
    controller: 'SearchCtrl'
  .otherwise
    redirectTo: '/'

  RestangularProvider.setBaseUrl('/api/');


#  $locationProvider.html5Mode(true)

console.log "starting app"
