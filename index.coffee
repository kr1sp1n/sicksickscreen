# file: index.coffee

express = require 'express'
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)

app.use express.static("#{__dirname}/public")
app.use express.static("#{__dirname}/bower_components")

clients = {}

# recursion!
getIndex = (index)->
  taken = false
  for id, client of clients
    taken = true if client.index == index
  if taken
    index += 1
    return getIndex index
  else
    return index

app.get '/', (req, res)->
  res.sendFile "#{__dirname}/public/index.html"

io.on 'connection', (socket)->
  clients[socket.id] = socket
  socket.index = getIndex 1
  console.log "client #{socket.index} connected"
  socket.emit 'index', socket.index
  socket.on 'disconnect', ->
    console.log "client #{socket.index} disconnected"
    delete clients[socket.id]

http.listen 3000, ->
  console.log 'listening on *:3000'
