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
  adapter = new Adapter "http://192.168.1.127", {port: 8931}
  @client = new Client "takumibaba", {adapter: adapter}
  @client.on "get_task", (result) =>
    window.plugin?.notification?.local?.add
      id: 1
      date: new Date().now
      message: result.key
      title: "get task..."
    @task.set
      cid: result.cid
      key: result.key
      format: result.format
      list: result.list
      description: result.description
  @client.on "returned", ->

  Backbone.history.start()
app.start()
