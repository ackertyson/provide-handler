class ProvideHandler
  constructor: (@models={}) ->
    for name, model of @models
      if @[name]?
        console.error "Model '#{name}' collides with existing handler method and will only be available as '@models.#{name}'"
      else
        @[name] = model
    @_proxy()

  _typeof: (subject, type) ->
    # typeof that actually works!
    Object::toString.call(subject).toLowerCase().slice(8, -1) is type

  _promisify: (callback) ->
    (req, res, next) =>
      try # run CALLBACK with actual Express params, catching any exceptions thrown
        proceed = callback.call @, req, res, next
      catch ex
        console.error '[provide-handler]', ex unless process.env.NODE_ENV is 'test'
        return next ex
      # wrap result in promise (in case it isn't already one) and process response
      Promise.resolve(proceed).then (data) ->
        res.status(200).json data
      , (err) ->
        console.error '[provide-handler]', err unless process.env.NODE_ENV is 'test'
        next err
      .catch () -> {} # prevent Node 'unhandledRejection' warnings

  _proxy:  ->
    @constructor::promises ?= {}
    for name, prop of @constructor::promises
      @constructor.prototype[name] = @_promisify prop

    @constructor::generators ?= {}
    for name, prop of @constructor::generators
      @constructor.prototype[name] = @_yields prop

  _yields: (callback) ->
    (args...) ->
      generator = callback.call @, args...
      handle = (result) ->
        return Promise.resolve result.value if result.done
        Promise.resolve(result.value).then (data) ->
          handle generator.next data
        , (err) ->
          handle generator.throw err
      try # initialize CALLBACK to first 'yield' call
        handle generator.next()
      catch ex
        Promise.reject ex


module.exports = ProvideHandler
