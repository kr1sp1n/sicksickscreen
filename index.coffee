# file: index.coffee

express = require 'express'
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)

port = process.env.PORT or 3000

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

  socket.on 'position', (position)->
    from_index = socket.index
    receiver = null
    if from_index == 1
      to_index = Object.keys(clients).length
    else
      to_index = from_index - 1

    for id, client of clients
      if client.index == to_index
        socket.to(client.id).emit('position', position)
        break


  socket.on 'disconnect', ->
    console.log "client #{socket.index} disconnected"
    delete clients[socket.id]

http.listen port, ->
  console.log "listening on *:#{port}"
