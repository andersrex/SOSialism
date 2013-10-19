express  = require 'express'
app = express()

app.configure ->
  app.set "port", process.env.PORT or 4000

app.get '/', (req, res) ->
  res.send 'test'

app.listen app.get('port'), ->
  console.log "Listening on port #{app.get('port')}"