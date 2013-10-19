#express  = require 'express'
#app = express()
#
#app.configure ->
#  app.set "port", process.env.PORT or 4000
#
#app.get '/', (req, res) ->
#  res.send 'test'
#
#app.listen app.get('port'), ->
#  console.log "Listening on port #{app.get('port')}"

express = require 'express'
routes = require './routes'
api = require './routes/api'
http = require 'http'
path = require 'path'

app = module.exports = express()

app.set('port', process.env.PORT || 4000)
app.set('views', __dirname + '/views')
app.set('view engine', 'jade')
app.use(express.logger('dev'))
app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(express.static(path.join(__dirname, 'public')))
app.use(app.router)

#app.use(require('less-middleware')({ src: __dirname + '/public' }))
#app.use(express.static(path.join(__dirname, 'public')))

if app.get('env') is 'development'
  app.use(express.errorHandler())

#if app.get('env') is 'production'

app.get '/', routes.index
#app.get '/templates/:name', routes.templates

app.get '/api/hospitals/:operation', api.hospitals
app.get '/api/operations', api.operations

app.get '*', routes.index

#app.listen app.get('port'), ->
#  console.log "Listening on port #{app.get('port')}"

http.createServer(app).listen app.get('port'), ->

console.log 'Express server listening on port ' + app.get('port')

#http.createServer(app).listen(app.get('port'), function () {
#console.log('Express server listening on port ' + app.get('port'));
#});