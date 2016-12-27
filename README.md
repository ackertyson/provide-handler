#provide-handler

Convenience wrapper for Express handlers.

##Installation

`npm i --save provide-handler`

##Usage

Handler methods are responsible only for processing whatever inputs they need
(e.g., req.params, req.body, etc.) and returning a value. That return value will
be wrapped in a Promise if it isn't already thenable. The usual Express `res,
res, next` are available within handler methods. However, for most common cases
this module does the work of processing the Express response, calling
`res.status(200).json` with the handler's return value on success and
`res.status(500).json` on failure.

Example handler (called by Express route):
```
Handler = require 'provide-handler'
Ticket = require '../models/ticket'

class TicketHandler
  # here we're dereferencing QUERY from req because it's all we need...
  get: ({ query }) ->
    Ticket.all query

  # ...and here we only need req.params....
  for_customer: ({ params }) ->
    Ticket.find_by_customer params.customer_id

module.exports = Handler.provide TicketHandler
```

If you need to return a status other than the default, you can call `res`
directly from your handler:
```
  # pass custom response back to Express...
  for_customer: ({ params }, res) ->
    Ticket.find_by_customer(params.customer_id).then (data) ->
      data
    .catch (err) ->
      res.status(404).json err
```

Handlers are called from Express app like:
```
express = require 'express'
handler = require '../handlers/ticket' # the example file above
app = express()

customer = express.Router()
customer.get '/:customer_id/tickets', handler.for_customer
app.use '/customer', customer

ticket = express.Router()
ticket.get '/', handler.get
app.use '/ticket', ticket
```

##Testing

`npm test`
