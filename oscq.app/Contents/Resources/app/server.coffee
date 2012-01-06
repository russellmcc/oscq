#
# server.coffee
#
# This is the entry point for the server.

express = require 'express'
require 'express-resource'


exports.start = (port, done) ->

  # start the server
  server = express.createServer()

  # set up push notifications
  (require './server/push').connect server

  server.use express.bodyParser()

  server.use express.errorHandler()

  # Resources
  server.use (server.resource 'routes', require './server/routes')
  server.use (server.resource 'outputs', require './server/outputs')
  server.use (server.resource 'inputs', require './server/inputs')

  # serve up all the batman stuff at /batman/*
  server.get '/batman/*', (req, res, next) ->
    req.url = '/' + req.params[0]
    express.static(__dirname + '/node_modules/batman/lib')(req, res, next)

  # serve up the client stuff at the root directory
  server.use express.static(__dirname + "/client")

  # Start UI server
  uiPort = port ? process.env.npm_package_config_port
  server.listen uiPort
  console.log "listening on #{uiPort}"

  done?()

if require.main is module
  exports.start()