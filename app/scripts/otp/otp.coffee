Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
global.jQuery = global.$ = $ = require 'jquery'
Bootstrap = require 'bootstrap-material-design/dist/js/material'
material = require 'bootstrap-material-design/scripts/material'
ripples = require 'bootstrap-material-design/scripts/ripples'

Views = require '../views'
Client = require 'babascript-client'
Adapter = require 'babascript-linda-adapter'
Logger = require 'babascript-plugin-logger'
Model = require '../model'
# app = require('../app')

class Router
  appRoutes:
    'a': 'b'

class Controller
  b: ->
    consol.elog 'bbbb'

app = new Marionette.Application()

app.addRegions
  'header': '#header'
  'main': '#main'
  'settings': '#settings'
  'login': '#login'
  'error': '#error'

app.router = new Router
  controller: new Controller()


app.addInitializer ->
  @task = new Model.Task()
  @header.show new Views.Header()
  @main.show new Views.Main
    model: @task
  Backbone.history.start()
  $.material.init()


app.start()
