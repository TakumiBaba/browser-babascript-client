Backbone = require 'backbone'
app = require './app'

class Task extends Backbone.Model
  defaults:
    description: ''
    example: ''

  cancel: (reason) ->
    console.log 'task cancel'
    console.log app
    console.log reason
    app.client.cancel @get('cid'), reason
    @clear()

class Tasks extends Backbone.Collection
  model: Task

module.exports =
  Task: Task
  Tasks: Tasks
