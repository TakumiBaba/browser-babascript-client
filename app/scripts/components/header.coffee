React = require 'react'
Kup   = require('react-kup')(React)

module.exports = Header = React.createClass
  getInitialState: ->
    return username: 'takumibaba'

  render: ->
    Kup ($) =>
      $.a className: 'header-title navbar-brand text-center', =>
        $.span @state.username