Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Client = require 'babascript-client'

class Router extends Marionette.AppRouter
  appRoutes:
    "": "to"
    "login": "login"
    "settings": "settings"
    ":tuplespace": "to"
    ":tuplespace/": "top"
    ":tuplespace/cancel": "cancel"
    ":tuplespace/:view": "client"

class Controller extends Marionette.Controller

  to: (tuplespace)->
    username = window.localStorage.getItem("username")
    app.router.navigate "/#{username}/", true

  top: (tuplespace)->
    app.main.currentView.changeView()

  client: (tuplespace, viewname)->
    if !app.task?
      return app.router.navigate "/#{tuplespace}/", true

  settings: ->

  login: ->
    app.login.show new require('./views').Login()

  cancel: ->
    console.log 'cancel'
    app.main.show new new require('./views').ThrowErrorView()

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
