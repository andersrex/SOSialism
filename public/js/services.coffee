services = angular.module 'app.services', []

services.factory 'geocoder', ($q, $rootScope) ->
  geocoder = new google.maps.Geocoder()

  return {
  geocode: (address) ->
    deferred = $q.defer()

    geocoder.geocode
      address: address
    , (results, status) ->
      if status is google.maps.GeocoderStatus.OK
        location = results[0].geometry.location
      else
        location = null

      deferred.resolve(location)
      $rootScope.$apply()

    return deferred.promise
  }
