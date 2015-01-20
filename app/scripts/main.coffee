Backbone = require 'backbone'
global.jQuery = global.$ = $ = require 'jquery'
Bootstrap = require 'bootstrap-material-design/dist/js/material'
material = require 'bootstrap-material-design/scripts/material'
ripples = require 'bootstrap-material-design/scripts/ripples'

Views = require './views'
Client = require 'babascript-client'
Adapter = require 'babascript-linda-adapter'
# Logger = require 'babascript-plugin-logger'
Model = require './model'
app = require('./app')

app.addInitializer ->
  @task = new Model.Task()
  @header.show new Views.Header()
  @main.show new Views.Main
    model: @task
  adapter = new Adapter "https://babascript-linda.herokuapp.com", {port: 443}
  @client = new Client "takumibaba", {adapter: adapter}
  @client.adapter.linda.io.on 'connect', ->
    console.log 'connect!!!'
  @client.on "get_task", (result) =>
    console.log result
    example = if result.options?.example? is true then "例: #{result.options.example}" else ''
    @task.set
      cid: result.cid
      key: result.key
      format: result.format
      list: result.options?.list
      description: result.options?.description
      example: example
    window.localStorage?.setItem 'task', JSON.stringify result
  @client.on "return_value", (value) =>
    window.localStorage?.setItem 'task', ""
  # @client.set "logger", new Logger()
  Backbone.history.start()

  task = window.localStorage?.getItem 'task'
  if task isnt ''
    console.log task
    task = JSON.parse task
    @client.getTask null, {data: task}

  $.material.init()

app.start()
