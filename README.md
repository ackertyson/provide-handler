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
