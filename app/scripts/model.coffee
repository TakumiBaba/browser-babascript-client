Backbone = require 'backbone'

class Task extends Backbone.Model
  defaults:
    description: ''

class Tasks extends Backbone.Collection
  model: Task

module.exports =
  Task: Task
  Tasks: Tasks
