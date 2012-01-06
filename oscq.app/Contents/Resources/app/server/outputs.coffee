#
# outputs.coffee
#
#
# This file provides a resource interface for OSC outputs.
#

# start with a "null" element.
outputs =
  0:
    id: 0
    address: ''
    port: null
    name: "None"
    active: true
    user: false

currid = 1

mdns = require 'node-bj'
osc = require 'osc-min'
dgram = require 'dgram'
routes = require './routes'
push = require './push'

sendSocket = dgram.createSocket 'udp4'

browser = mdns.createBrowser (new mdns.RegType 'osc', 'udp')
browser.on 'serviceDown', (rinfo) ->
  for id, output of outputs
    if output.name is rinfo.serviceName
      output.active = false
      for rid, route of routes.routes
        route.output_id = 0 if route.output_id is id
      push.emit 'output change', {}

browser.on 'serviceUp', (rinfo) ->
  # if it's an existing ouptut, just set it as active
  for id, output of outputs
    if output.name is rinfo.serviceName
      output.active = true
      return

  # ignore if we should
  return if module.exports.ignore?(rinfo)

  newOutput =
    id: currid++
    address: rinfo.host ? ''
    port: rinfo.port ? null
    name: rinfo.serviceName ? ''
    active: true
    user : false
  outputs[newOutput.id] = newOutput
  push.emit 'output change', {}

browser.start()

doIfUserOutput = (res, output, fn) ->
  if outputs[output]?
    if outputs[output].user
      fn output
      res.send 200
    else
      res.send 403
  else
    res.send 404

module.exports = {
  outputs : outputs
  index : (req, res) ->
    allOutputs = for id,output of outputs
      output
    res.json {outputs: allOutputs}
  show : (req, res) ->
    if outputs[req.params.output]?
      res.json {output: outputs[req.params.output]}
    else
      res.send 404
  create : (req, res) ->
    port = parseInt req.body?.output?.port
    port = null if isNaN port
    newOutput =
      id : currid++
      address : req.body?.output?.address ? ''
      port : port
      user : true
      name : req.body?.output?.name ? ''
      active : true
    outputs[newOutput.id] = newOutput
    res.json {output: newOutput}
  destroy : (req, res) ->
    doIfUserOutput res, req.params.output, (output) ->
      delId = outputs[output].id
      delete outputs[output]
      for id, route of routes.routes
        route.output_id = 0 if route.output_id is delId

  update : (req, res) ->
    doIfUserOutput res, req.params.output, (output) ->
      outputs[output] = req.body.output

  sendMessageToOutputID : (msg, outputID) ->
    return if not outputID?
    if outputID < 0 # negative ids mean go to all outputs.
      for id, output of outputs
        module.exports.sendMessageToOutputID msg, id
      return
    try
      if not Buffer.isBuffer msg
        msg = osc.toBuffer msg
      if outputs[outputID]? and outputs[outputID].port
        sendSocket.send msg, 0, msg.length, outputs[outputID].port, outputs[outputID].address
    catch error
      console.log error
}
