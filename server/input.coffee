dgram = require 'dgram'
mdns = require 'mdns'
osc = require 'osc-min'
routes = require './routes'
outputs = require './outputs'
push = require './push'

module.exports = (@port, @name, @id) ->
  # parse port if it's a string.
  if typeof @port is 'string'
    @port = parseInt @port
    @port = 0 if isNaN @port

  @dgram = dgram.createSocket 'udp4', (msg, rinfo) =>
    try
      routeOutput = null
      rerouted = osc.applyAddressTransform msg, (address) =>
        for id, route of routes.routes
          if (((route.input_id is @id) or (route.input_id is 1)) and ((route.match is '*') or (route.match is address)))
            # we matched a route
            routeOutput = route.output_id if (route.output_id > 0)
            push.emit 'blink route', id
            return route.reroute ? address
        if @createRouteOnReceive
          newRoute =
            input_id: @id
            output_id: 0
            match: address
          routes.addRoute newRoute
          push.emit 'route change', {}
        address
      outputs.sendMessageToOutputID rerouted, routeOutput if routeOutput?
    catch error
      console.log error
  @dgram.bind @port
  @port = @dgram.address().port
  @ad = mdns.createAdvertisement (new mdns.udp 'osc'), @port, {name: name}
  @ad.start()
  @json = =>
    return {
      port: @port
      id: @id
      name: @name
    }
  @stop = =>
    try
      @ad.stop()
      @dgram.close()
    catch error
      console.log error
  @createRouteOnReceive = true
  @