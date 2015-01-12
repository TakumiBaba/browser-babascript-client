Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Client = require 'babascript-client'

class Router extends Marionette.AppRouter
  appRoutes:
    "": "todo" # todo list interface
    "done": "done" # done todo list interaface
    "tasks/:cid": 'returnview' # return value interface

class Controller extends Marionette.Controller

  todo: ->
    console.log 'todo list interface'
    app.task.clear()
    # app.main.currentView.changeView()

  done: ->
    console.log 'done list interface'

  returnview: (cid) ->
    task = app.tasks.where({cid: cid})[0]
    return app.router.navigate '/', true if !task?
    app.task.set task.attributes
    # app.task.set
    #   cid: task.get 'cid'
    #   key: task.get 'key'
    #   format: task.get 'format'
    #   list: task.get 'list'
    #   description: task.get 'description' or ''
    # app.main.currentView.changeView()

app = new Marionette.Application()

app.addRegions
  'header': '#header'
  'main': '#main'
  'settings': '#settings'
  'login': '#login'
  'error': '#error'

app.router = new Router
  controller: new Controller()

module.exports = app
