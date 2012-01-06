require [], ->
  class OSCRoute extends Batman.App
    @global yes

  # Models
  class OSCRoute.Input extends Batman.Model
    @global yes
    @persist Batman.RestStorage
    @encode 'name', 'port'
    @hasMany 'route'
    @accessor 'showInList',
      get: ->
        (@get 'id') > 1
    port: 0
    name: ''

  class OSCRoute.Output extends Batman.Model
    @global yes
    @persist Batman.RestStorage
    @encode 'name', 'port', 'address', 'active', 'user'
    @accessor 'showInList',
      get: ->
        ((@get 'active') or (@get 'user')) and ((@get 'id') isnt 0)
    @accessor 'activeName',
      get: ->
        "#{@get 'name'}#{(if (@get 'active') then '' else ' [Inactive]')}"
    @hasMany 'route'
    user: true

  # this hack allows us to not bind the url to the belongs to.
  delete Batman.BelongsToAssociation.prototype.url if Batman.BelongsToAssociation.prototype.url?

  hide_elem = (e) -> -> $("##{e}").toggleClass 'deadToMe'

  class OSCRoute.Route extends Batman.Model
    @global yes
    @persist Batman.RestStorage
    @encode 'match', 'reroute'
    @belongsTo 'input',
      autoload: false
    @belongsTo 'output',
      autoload: false
    @accessor 'blinkID',
      get: ->
        "blink#{@get 'id'}"

  # Controllers
  class OSCRoute.RoutesController extends Batman.Controller
    constructor: ->
      @set 'editRoute', new Route

    create: =>
      @editRoute.save =>
        @set 'editRoute', new Route

    hide: hide_elem 'routes'

  class OSCRoute.InputsController extends Batman.Controller
    constructor: ->
      @set 'editInput', new Input

    hide: hide_elem 'inputs'

    create: =>
      @editInput.save =>
        @set 'editInput', new Input

  class OSCRoute.OutputsController extends Batman.Controller
    constructor: ->
      @set 'editOutput', new Output

    hide: hide_elem 'outputs'

    create: =>
      @editOutput.save =>
        @set 'editOutput', new Output

  socket = io.connect()
  socket.on 'route change', ->
    OSCRoute.Route.load ->
  socket.on 'output change', ->
    OSCRoute.Output.load ->

  blinkRoutines = {}
  socket.on 'blink route', (id) ->
    $("\#blink#{id}").addClass 'blink'
    $("\#blink#{id}").removeClass 'unblink'
    unblink = ->
      $("\#blink#{id}").removeClass 'blink'
      $("\#blink#{id}").addClass 'unblink'
    clearTimeout blinkRoutines[id] if blinkRoutines[id]?
    blinkRoutines[id] = setTimeout unblink, 400

  OSCRoute.on 'ready', ->
    $('.loading').removeClass 'loading'
  OSCRoute.run()