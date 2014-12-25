Backbone = require 'backbone'
Views = require './views'
Client = require 'babascript-client'
Adapter = require 'babascript-linda-adapter'
Logger = require 'babascript-plugin-logger'
Model = require './model'
app = require('./app')

app.addInitializer ->
  @task = new Model.Task()
  @header.show new Views.Header()
  @main.show new Views.Main
    model: @task
  adapter = new Adapter "https://babascript-linda.herokuapp.com", {port: 443}
  console.log adapter
  @client = new Client "takumibaba", {adapter: adapter}
  @client.on "get_task", (result) =>
    @task.set
      cid: result.cid
      key: result.key
      format: result.format
      list: result.list
      description: result.description
  @client.on "return_value", (result) ->
  @client.set "logger", new Logger()
  Backbone.history.start()
app.start()
