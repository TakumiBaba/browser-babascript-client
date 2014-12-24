Backbone = require 'backbone'
Views = require './views'
Client = require 'babascript-client'
Adapter = require 'babascript-linda-adapter'
Model = require './model'
app = require('./app')

app.addInitializer ->
  @task = new Model.Task()
  @header.show new Views.Header()
  @main.show new Views.Main
    model: @task
  # adapter = new Adapter "http://localhost", {port: 8931}
  # console.log adapter
  @client = new Client "takumibaba"
  @client.on "get_task", (result) =>
    @task.set
      cid: result.cid
      key: result.key
      format: result.format
      list: result.list
      description: result.description
  @client.on "return_value", ->

  Backbone.history.start()
app.start()
