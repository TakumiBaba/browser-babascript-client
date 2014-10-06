React = require 'react'
Kup = require('react-kup')(React)

LindaAdapter = require 'babascript-linda-adapter'
Client = require 'babascript-client'

Header = require './components/header'
Footer = require './components/footer'
Order  = require './components/order'
Views  = require './components/views'

client = require './client'

order = new Order()

header = React.renderComponent new Header(), document.getElementById "header"
order = React.renderComponent new Order(), document.getElementById "order"
returnv = React.renderComponent new Views.Disable(), document.getElementById 'returnvalue'

client.on "get_task", (task) ->
  console.log task
  format = task.format
  console.log order
  order.setState {order: task.key}
  view = switch format
    when "boolean"
      new Views.Boolean()
    when "string"
      new Views.String()
    when "list"
      new Views.List({list: task.options.list})
    when "number"
      new Views.Number()
  React.renderComponent view, document.getElementById "returnvalue"
client.on "return_value", ->
  React.renderComponent new Views.Disable(), document.getElementById 'returnvalue'

# tasks = [
#   {text: 'are', status: null}
#   {text: 'are', status: null}
#   {text: 'are', status: null}
#   {text: 'are', status: null}
#   {text: 'are', status: null}
#   {text: 'are', status: null}

# ]
# header = new Header()
# React.renderComponent new Views.Boolean(), document.getElementById 'returnvalue'
# React.renderComponent new Views.String(), document.getElementById 'returnvalue'
# React.renderComponent new Views.Number(), document.getElementById 'returnvalue'
# React.renderComponent new Views.List({list: [1,2,3,4,5]}), document.getElementById 'returnvalue'
