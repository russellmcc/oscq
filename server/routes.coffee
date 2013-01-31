#
# routes.coffee
#
# This file contains both the in-memory storage and the view code
# for the routes available.
#

routes = {}
currid = 0
_ = require 'underscore'

module.exports = {
  routes: routes

  index: (req, res) ->
    allRoutes = for id,route of routes
      route
    res.json {routes: allRoutes}

  addRoute: (route) ->
    if not route.id?
      route.id = currid++
    routes[route.id] = route

  create: (req, res) ->
    newRoute =
      match: req.body.route.match ? "*"
      reroute: req.body.route.reroute ? null
      output_id: req.body.route.output_id ? 0
      input_id: req.body.route.input_id ? 0

    module.exports.addRoute newRoute
    res.json {route: newRoute}

  show: (req, res, next) ->
    if routes[req.params.route]?
      res.json {route: routes[req.params.route]}
    else
      res.send 404

  update: (req, res, next) ->
    unless req.body.route?
      res.send 404
      return

    if routes[req.params.route]?
      req.body.route.id = routes[req.params.route].id
      for key in ['input_id', 'output_id']
        if req.body.route[key]?
          if(typeof req.body.route[key]) is 'string'
            req.body.route[key] = parseInt req.body.route[key]
            req.body.route[key] = 0 if isNaN req.body.route[key]
        else
          req.body.route[key] = 0
      routes[req.params.route] = req.body.route
      res.json {route: routes[req.params.route]}
    else
      res.send 404

  destroy: (req, res) ->
    if routes[req.params.route]?
      delete routes[req.params.route]
      res.json {}
    else
      res.send 404
}

