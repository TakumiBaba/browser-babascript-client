window.Backbone = Backbone = require 'backbone'
Views = require './views'
Client = require 'babascript-client'
Adapter = require 'babascript-linda-adapter'
Logger = require 'babascript-plugin-logger'
Model = require './model'
Application = require('./app')

Application.addInitializer ->
  @task = new Model.Task()
  @tasks = new Model.Tasks()
  @header.show new Views.Header()
  @main.show new Views.Main
    model: @task
  username = window.localStorage.getItem('username') or 'takumibaba'
  adapter = new Adapter "https://babascript-linda.herokuapp.com", {port: 443}
  @client = new Client.Stream username, {adapter: adapter, stream: true}
  @client.on 'stream', (err, tuple) =>
    console.log 'stream'
    console.log arguments
    console.log tuple.data.cid
    task = new Model.Task tuple.data
    @tasks.push task
    # @router.navigate "/tasks/#{tuple.data.cid}", true
  @client.on 'cancel_task', ->
    console.log 'cancel'
    console.log arguments
  # @client.stream (err, data) ->
  #   console.log 'stream'
  #   console.log data
  # @client.on "get_task", (result) =>
  #   @task.set
  #     cid: result.cid
  #     key: result.key
  #     format: result.format
  #     list: result.list
  #     description: result.description
  #   window.localStorage?.setItem 'task', JSON.stringify result
  @client.on "return_value", (tuple) =>
    window.localStorage?.setItem 'task', ""
  @client.set "logger", new Logger()
  console.log 'start....'
  task = window.localStorage?.getItem 'task'
  if task isnt ''
    task = JSON.parse task
    @client.addDefaultTask {data: task}

  Backbone.history.start()
Application.start()
