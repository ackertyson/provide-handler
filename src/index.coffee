Promise = require 'promise'

class ProvideHandler
  # centralize all Express handler response logic by wrapping handler methods in
  #  helper function; note that these are static (not instance) methods...

  @provide: (Handler, name, schema) ->
    h = new Handler
    @_wrap h

  @_typeof: (subject, type) ->
    # typeof that actually works!
    Object::toString.call(subject).toLowerCase().slice(8, -1) is type

  @_wrap: (obj) ->
    for name, prop of obj
      obj[name] = @_wrapper prop if @_typeof prop, 'function'
      if @_typeof prop, 'object'
        obj[name] = prop
        @_wrap prop
    obj

  @_wrapper: (callback) ->
    (req, res, next) ->
      try # run CALLBACK with actual Express params, catching any exceptions thrown
        proceed = callback req, res, next
      catch ex
        return res.status(500).json ex
      # wrap result in promise (in case it isn't already one) and process response
      Promise.resolve(proceed).then (data) ->
        res.status(200).json data
      , (err) ->
        res.status(500).json err


module.exports = ProvideHandler
