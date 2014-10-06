React = require 'react'
Kup = require('react-kup')(React)

module.exports = Footer = React.createClass
  render: ->
    Kup ($) ->
      $.div id: 'returnvalue'

