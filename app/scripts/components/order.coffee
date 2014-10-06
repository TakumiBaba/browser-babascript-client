React = require 'react'
Kup   = require('react-kup')(React)

module.exports = Order = React.createClass
  getInitialState: ->
    return order: null
  render: ->
    Kup ($) =>
      $.div className: 'well', =>
        # $.div className: 'page-header', =>
        $.h1 className: 'text-center', @state.order
        # $.div className: 'description', =>


# Order = React.createClass
#   # status is [send, receive, return, cancel]
#   setInitialState: ->
#     return {
#       text: ''
#       status: null
#     }

#   render: ->
#     Kup ($) =>
#       $.div className: 'well', style:
#           width: '80%'
#       , =>
#         text = @props.text
#         $.span text



# module.exports = OrderList = React.createClass
#   render: ->
#     # orders = @props.data.map (order) ->
#     #   return Kup ($) ->
#     #     $.component Order, {text: 'hogehoge', status: 'read'}
#     Kup ($) =>
#       $.div className: 'list', =>
#         for order in @props.data
#           $.component Order, order

