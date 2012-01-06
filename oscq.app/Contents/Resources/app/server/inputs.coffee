#
# inputs.coffee
#
# This file contains both the in-memory storage and the view code
# for the inputs available.
#

inputs =
  1:
    json: ->
      id: 1
      name: "All Inputs"
  0:
    json: ->
      id: 0
      name: "No Input"

currid = 2

Input = require './input'
outputs = require './outputs'
routes = require './routes'

outputs.ignore = (rinfo) ->
  for id, input of inputs
    return true if (input.name is rinfo.serviceName[0...(input.name?.length ? 0)]) and (input.port is rinfo.port)
  return false

module.exports = {
  inputs: inputs

  index: (req, res) ->
    allInputs = for id,input of inputs
      input.json()
    res.json {inputs: allInputs}

  create: (req, res) ->
    port = req.body.input.port ? 0
    name = req.body.input.name || 'Untitled Input'
    id = currid++
    newInput = new Input port, name, id
    inputs[id] = newInput
    res.json {input: newInput.json()}

  update: (req, res, next) ->
    if (req.params.input > 1) and inputs[req.params.input]?
      inputs[req.params.input].stop()
      port = req.body.input.port ? 0
      name = req.body.input.name || 'Untitled Input'
      id = req.params.input
      inputs[id] = new Input port, name, id
      res.json {input: inputs[id].json()}
    else
      res.send 404

  show: (req, res, next) ->
    if inputs[req.params.input]?
      res.json {input: inputs[req.params.input].json()}
    else
      res.send 404

  destroy: (req, res) ->
    if (req.params.input > 1) and  inputs[req.params.input]?
      inputs[req.params.input].stop()
      delId = inputs[req.params.input].id
      delete inputs[req.params.input]
      for id, route of routes.routes
        route.input_id = 0 if route.input_id is delId
      res.json {}
    else
      res.send 404
}

newInput = new Input 41234, 'OSCQ', currid
inputs[currid++] = newInput
