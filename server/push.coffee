io = null

module.exports =
  connect: (server) ->
    io = (require 'socket.io').listen server
  emit: (msg, data) ->
    io.sockets.emit msg, data