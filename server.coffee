#
# server.coffee
#
# This is the entry point for the server.

express = require 'express'
require 'express-resource'


exports.start = (port) ->

  # start the server
  app = express()
  server = (require 'http').createServer app


  # set up push notifications
  (require './server/push').connect server

  app.use express.bodyParser()

  app.use express.errorHandler()

  # Resources
  app.use (app.resource 'routes', require './server/routes')
  app.use (app.resource 'outputs', require './server/outputs')
  app.use (app.resource 'inputs', require './server/inputs')

  # serve up all the batman stuff at /batman/*
  app.get '/batman/*', (req, res, next) ->
    req.url = '/' + req.params[0]
    express.static(__dirname + '/node_modules/batman/lib')(req, res, next)

  # serve up the client stuff at the root directory
  app.use express.static(__dirname + "/client")

  # Start UI server
  uiPort = port ? 8124 # process.env.npm_package_config_port
  server.listen uiPort
  console.log "listening on #{uiPort}"

  return uiPort

if require.main is module
  exports.start()  