#provide-handler

Convenience wrapper for Express handlers.

##Installation

`npm i --save provide-handler`

##Usage

Handler (called by Express route):
```
Handler = require 'provide-handler'
Ticket = require '../models/ticket'

class TicketHandler
  # req is passed from Express; here we're dereferencing BODY from req
  #  because it's all we need...
  get: ({ body }) ->
    Ticket.all body._filters

  # ...and here we only need req.params....
  for_customer: ({ params }) ->
    Ticket.find_by_customer params.customer_id

module.exports = Handler.provide TicketHandler
```

Call handler like:
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
