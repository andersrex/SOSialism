angular.module('app', [
  'ngRoute',
  'app.controllers',
  'app.services',
]).config ($routeProvider, $locationProvider) ->
  $routeProvider.when '/',
    templateUrl: 'templates/index.html',
    controller: 'IndexCtrl'
  .when '/search',
    templateUrl: 'templates/search.html',
    controller: 'SearchCtrl'
  .otherwise
    redirectTo: '/'

#  $locationProvider.html5Mode(true)

console.log "starting app"
