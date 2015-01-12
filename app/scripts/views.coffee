Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
global.jQuery = $ = require 'jquery'
Bootstrap = require 'bootstrap/dist/js/bootstrap'
app = require './app'

class BaseView extends Marionette.ItemView
  tagName: "div"

  initialize: ->

  events:
    "touchstart button": "active"
    "touchend button": "normal"
    'submit': "submitcancel"

  active: (e) ->
    $(e.currentTarget).addClass 'active'
  normal: (e) ->
    $(e.currentTarget).removeClass 'active'

  submitcancel: ->
    return false

  returnValue: (value, option={})->
    # app.client.emit 'return_value'
    cid = app.task.get 'cid'
    app.client.returnValue value, cid, option
    app.tasks.remove app.tasks.where {cid: cid}
    console.log 'return value ie-i'
    console.log app
    app.task.clear()
    window.plugins?.toast?.show "返り値: #{value}", "short", "center"

  cancel: ->
    console.log app
    cid = app.task.get 'cid'
    app.task.clear()
    app.client.emit 'cancel_task'
    app.client.cancel cid, 'client side cancel'

class HeaderView extends Marionette.ItemView
  template: '#header-template'
  className: 'container'
  ui:
    cancel: 'a.cancel-button'
    setting: 'a.settings-button'
    logout: 'a.logout'
    name: 'a.header-title'
    back: 'button.back-button'
  events:
    'click @ui.back': 'back'
    "click @ui.logout": 'logout'
    'click @ui.cancel': 'cancelTask'
    'click @ui.setting': 'settings'

  initialize: ->

  cancelTask: ->
    # キャンセルビュー出す
    return if !app.task?
    # App.router.navigate "/#{App.username}/cancel"
    # app.error.destroy()
    app.error.show new ThrowErrorView()

  settings: ->
    console.log 'settings'
    app.settings.show new SettingsView()

  back: ->
    app.task.clear()
    app.router.navigate '', true

  logout: ->
    $.ajax
      type: "DELETE"
      url: "#{app.API}/api/session/logout"
      xhrFields:
        withCredentials: true
    .always ->
      window.location.reload()

class SettingsView extends Marionette.ItemView
  template: '#settings-template'
  className: 'modal-dialog'
  ui:
    username: 'input#username'
    update: 'button.update'
    logout: 'button.logout'
    close: 'button.close'
  events:
    "click @ui.update": 'update'
    "click @ui.logout": 'logout'
    "click @ui.close": 'close'
  update: ->
    username = @ui.username.val()
    return if !username? or username.length is 0
    window.localStorage.setItem "username", username
    @$el.modal()
    @logout()
    window.location.reload()
  logout: ->
    $.ajax
      type: "DELETE"
      url: "#{app.API}/api/session/logout"
      xhrFields:
        withCredentials: true
    .always ->
      window.location.reload()
  close: ->
    # app.settings.close()
    # @$el.modal()

class LoginView extends Marionette.ItemView
  template: '#login-template'
  className: 'modal-dialog'
  style: ''
  ui:
    username: 'input#username'
    password: 'input#password'
    login: 'button.login'
    signup: 'button.signup'
  events:
    "click @ui.login": 'login'
    "click @ui.signup": 'signup'
  login: ->
    username = @ui.username.val()
    password = @ui.password.val()
    $.ajax
      type: "POST"
      url: "#{app.API}/api/session/login"
      data:
        username: username
        password: password
      xhrFields:
        withCredentials: true
    .done (res)=>
      window.localStorage.setItem "username", username
      app.router.navigate "/", true
      window.location.reload()
    .error ->
      window.alert "invalid username or password "
  signup: ->
    console.log 'singnup'
    username = @ui.username.val()
    password = @ui.password.val()
    $.ajax
      type: "POST"
      url: "#{app.API}/api/user/new"
      data:
        username: username
        password: password
      xhrFields:
        withCredentials: true
    .done (res)=>
      window.localStorage.setItem "username", username
      $.ajax
        type: "POST"
        url: "#{app.API}/api/session/login"
        data:
          username: username
          password: password
        xhrFields:
          withCredentials: true
      .done (res) ->
        app.router.navigate "/", true
        window.location.reload()
      .error (error)->
        window.alert "invalid username or password "
    .error ->
      window.alert "invalid username or password "

class MainView extends Marionette.LayoutView
  template: '#main-template'
  regions:
    returnview: '#returnview'
  modelEvents:
    "change": "changeView"
  initialize: ->

  changeView: ->
    cid = @model.get 'cid'
    @returnview.reset()
    if !cid?
      @returnview.show new TodoListView()
    else
      app.client.accept @model.get('cid'), (err, tuple) =>
        throw err if err
        format = @model?.get 'format' or @model?.get('options')?.format
        console.log @model
        viewClass = switch format
          when "", "index"
            NormalView
          when "boolean", "bool"
            BooleanView
          when "string"
            StringView
          when "list"
            ListView
          when "number", "int"
            NumberView
          when "void"
            VoidView
          when "camera"
            CameraView
          else
            NormalView
        @returnview.show new viewClass {model: @model}

class TodoView extends Marionette.ItemView
  template: '#todo-template'
  events:
    'click': 'clicked'
  clicked: ->
    app.router.navigate "tasks/#{@model.get('cid')}", true
    console.log @

class TodoListView extends Marionette.CollectionView
  tagName: 'ul'
  className: 'todo-list'
  childView: TodoView

  initialize: ->
    console.log 'todo list view'
    @collection = app.tasks
    console.log @

class NormalView extends BaseView
  template: '#normal-template'
  className: 'normal-page'

class BooleanView extends BaseView
  template: '#boolean-template'
  className: 'boolean-page'
  ui:
    truebutton: 'button.true'
    falsebutton: 'button.false'
  events:
    'click @ui.truebutton': 'returntrue'
    'click @ui.falsebutton': 'returnfalse'
  returntrue: ->
    @returnValue true
  returnfalse: ->
    @returnValue false

class StringView extends BaseView
  template: '#string-template'
  className: 'string-page'
  ui:
    input: 'input.string-value'
    button: 'button'
  events:
    'click @ui.button': 'returnString'
  returnString: ->
    @returnValue @ui.input.val()

class ListView extends BaseView
  template: '#list-template'
  className: 'list-page'
  ui:
    select: 'select'
    button: 'button'
  events:
    'click @ui.button': 'returnSelect'
  returnSelect: ->
    value = @ui.select.val()
    console.log value
    @returnValue value

class NumberView extends BaseView
  template: '#number-template'
  className: 'number-page'
  ui:
    input: 'input.number-value'
    button: 'button'
  events:
    'click @ui.button': 'returnNumber'
  returnNumber: ->
    @returnValue @ui.input.val()

class VoidView extends BaseView
  template: '#void-template'
  className: 'void-page'
  ui:
    button: 'button.void'
  events:
    'click @ui.button': 'returnVoid'
  returnVoid: ->
    @returnValue 'true'

class CameraView extends BaseView
  template: '#camera-template'
  className: 'camera-page'
  ui:
    'camera': "input.camera"
  events:
    'change @ui.camera': 'change'
  change: (e) ->
    console.log e
    f = e.target.files[0]
    return if !f? or !f.type.match "image.*"
    reader = new FileReader()
    reader.onload = (e) =>
      @returnValue e.target.result
    reader.readAsBinaryString f


class Task extends Backbone.Model

  initialize: ->
    @$el.html @template()


class ThrowErrorView extends Marionette.ItemView
  template: '#throw-error-template'
  className: 'throw-error-page modal fade'
  style: 'top: 100px'
  ui:
    cancel: 'button.cancel'
    return: 'button.return'
    input: 'input.string-value'
    select: 'select.setphrase'
  events:
    'click @ui.cancel': 'cancel'
    'click @ui.return': 'return'
  initialize: ->
    @model = new Backbone.Model
      key: app.task.get 'key'
    $(@el).css 'top', '30px'
  onRender: ->
    $(@el).modal('show')

  onBeforeDestroy: ->
    console.log arguments
    console.log 'before destroy'
    $(@el).modal "hide"

  cancel: ->
    if @ui.input.val() isnt ""
      cause = @ui.input.val()
    else
      cause = @ui.select.val()
    console.log cause
    cid = app.task.get 'cid'
    app.client.emit 'cancel_task'
    app.client.cancel cid, cause
    app.task.reset()
    @destroy()

  return: ->
    # $(@el).modal 'hide'
    # setTimeout =>
    #   @destroy()
    #   console.log @
    # , 1000
    @destroy()

class DoneListView
  template: '#done-list-view'

module.exports =
  Header: HeaderView
  Base: BaseView
  Main: MainView
  Normal: NormalView
  Boolean: BooleanView
  String: StringView
  List: ListView
  Number: NumberView
  Void: VoidView
  Task: Task
  Login: LoginView
  Settings: SettingsView
  ThrowError: ThrowErrorView
