React = require 'react'
Kup = require('react-kup')(React)

client = require '../client'

BooleanView = React.createClass
  render: ->
    Kup ($) =>
      $.div className: 'btn-group booleanview', =>
        $.button
          type: 'button'
          className: 'btn btn-primary btn-lg btn-block'
          id: 'yes'
          onClick: @returnValue
        , ->
          $.span "YES"
        $.button
          type: 'button'
          className: 'btn btn-danger btn-lg btn-block'
          id: 'no'
          onClick: @returnValue
        , ->
          $.span "NO"

  returnValue: (e) ->
    client.returnValue e.target.id

StringView = React.createClass
  getInitialState: ->
    return value: ''
  render: ->
    Kup ($) =>
      $.div className: 'input-group', =>
        $.input
          id: 'string-input'
          type: 'text'
          className: 'form-control'
          value: @state.value
          onChange: @onHandleChange
        $.span className: 'input-group-btn', =>
          $.button
            type: 'button'
            className: 'btn btn-default'
            onClick: @returnValue
            "send"
  onHandleChange: (e)->
    @setState value: e.target.value
  returnValue: ->
    v = @state.value
    client.returnValue v

ListView = React.createClass
  getInitialState: ->
    return value: @props.list[0]
  render: ->
    Kup ($) =>
      $.div className: 'input-group', =>
        $.select
          className: 'form-control'
          value: @state.value
          onChange: @onHandleChange
        , =>
          for item in @props.list
            $.option item
        $.span className: 'input-group-btn', =>
          $.button
            type: 'button'
            className: 'btn btn-default'
            onClick: @returnValue
            "send"          
  onHandleChange: (e) ->
    @setState value: e.target.value
  returnValue: ->
    client.returnValue @state.value

NumberView = React.createClass
  getInitialState: ->
    return value: null
  render: ->
    Kup ($) =>
      $.div className: 'input-group', =>
        $.input
          type: 'number'
          className: 'form-control'
          onChange: @onHandleChange
        $.span className: 'input-group-btn', =>
          $.button
            type: 'button'
            className: 'btn btn-default'
            onClick: @returnValue
            "send"
  onHandleChange: (e) ->
    @setState value: e.target.value

  returnValue: ->
    v = @state.value
    client.returnValue v

DisableView = React.createClass
  render: ->
    Kup ($) =>
      $.div className: 'btn-group booleanview', =>
        $.button
          type: 'button'
          className: 'btn btn-primary btn-lg btn-block'
          disabled: 'disabled'
        , ->
          $.span "wait..."

ImageView = React.createClass
  render: ->

module.exports =
  Boolean: BooleanView
  String: StringView
  List: ListView
  Number: NumberView
  Disable: DisableView