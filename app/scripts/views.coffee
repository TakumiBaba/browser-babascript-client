Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
app = require './app'
_ = require 'lodash'

class BaseView extends Marionette.ItemView
  tagName: "div"
  ui:
    errorButton: 'a.throw-error-button'
  events:
    # "touchstart button": "active"
    # "touchend button": "normal"
    # 'submit': "submitcancel"
    'click @ui.errorSubmit': 'throwError'

  initialize: ->

  submitcancel: ->
    return false

  returnValue: (value, option={})->
    # app.client.emit 'return_value'
    setTimeout ->
      cid = app.task.get 'cid'
      app.client.returnValue value, cid, option
      app.tasks.remove app.tasks.where {cid: cid}
      console.log 'return value ie-i'
      console.log app
      app.task.clear()
      window.plugins?.toast?.show "返り値: #{value}", "short", "center"
    , 300

  cancel: ->
    console.log app
    setTimeout ->
      cid = app.task.get 'cid'
      app.task.cancel()
      app.task.clear()
      app.client.emit 'cancel_task'
      app.client.cancel cid, 'client side cancel'
    , 300

  error: (e) ->
    console.log 'error view'
    console.log app.main.currentView.returnview.currentView.$el.find('.error').removeClass 'fade'
    # console.log app.main.currentView.returnview.currentView.show new ThrowErrorView()

  throwError: ->
    console.log 'throw error'
    setTimeout ->
      cid = app.task.get 'cid'
      input = app.main.currentView.returnview.currentView.$el.find('.error input').val()
      select = app.main.currentView.returnview.currentView.$el.find('.error select').val()
      reason = if input is '' then select else input
      app.tasks.remove app.tasks.where {cid: cid}
      app.task.cancel reason
      app.client.emit 'cancel_task'
    , 300
    # app.client.cancel cid, 'client side cancel'

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
    # ここで、adapter.sendしたい
    app.client.adapter.send app.task.toJSON()
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
      tid = setTimeout ->
        console.log 'timeout....'
        @returnview.show new TodoListView()
      , 5000
      app.client.accept @model.get('cid'), (err, tuple) =>
        clearInterval tid
        @change err, tuple

  change: (err, tuple) =>
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
  region: 'error': '.error'
  ui:
    truebutton: 'button.yes-button'
    falsebutton: 'button.no-button'
    errorButton: 'a.error-button'
    errorSubmit: 'button.error-submit'
  events:
    'click @ui.truebutton': 'returntrue'
    'click @ui.falsebutton': 'returnfalse'
    'click @ui.errorButton': 'error'
    'click @ui.errorSubmit': 'throwError'
  returntrue: ->
    @returnValue true
  returnfalse: ->
    @returnValue false

# inputの中身が取れない
class StringView extends BaseView
  template: '#string-template'
  className: 'string-page'
  ui:
    input: 'input.string-value'
    button: 'button.submit'
    errorButton: 'a.error-button'
    errorSubmit: 'button.error-submit'
  events:
    'click @ui.button': 'returnString'
    'click @ui.input': 'onFocus'
    'click @ui.errorButton': 'error'
    'click @ui.errorSubmit': 'throwError'

  onRender: ->
    Backbone.$.material.input($(@ui.input))

  # onFocus: ->
  #   Backbone.$.material.input($(@ui.input))

  returnString: ->
    console.log @ui.input
    @returnValue @ui.input.val()

class ListView extends BaseView
  template: '#list-template'
  className: 'list-page'
  ui:
    select: 'select'
    button: 'button'
    a: 'a.item'
    errorButton: 'a.error-button'
    errorSubmit: 'button.error-submit'
  events:
    'click @ui.a': 'returnSelect'
    'click @ui.button': 'returnSelect'
    'click @ui.errorButton': 'error'
    'click @ui.errorSubmit': 'throwError'

  returnSelect: (e) ->
    value = e.target.id
    @returnValue value

class NumberView extends BaseView
  template: '#number-template'
  className: 'number-page'
  ui:
    form: 'form.number-form'
    input: 'input.number-value'
    button: 'button.return-submit'
    submit: 'input.submit'
    error: 'a.error-button'
    errorSubmit: 'button.error-submit'
  events:
    'click @ui.button': 'returnNumber'
    'submit @ui.form': 'returnNumber'
    'click @ui.error': 'error'
    'click @ui.errorSubmit': 'throwError'

  onRender: ->
    Backbone.$.material.input($(@ui.input))

  returnNumber: (e) ->
    val = parseInt @ui.input.val(), 10
    console.log val
    return false if _.isNaN(val) is true
    if _.isNumber(val) is true
      console.log 'ok'
      @returnValue @ui.input.val()
    return false


class VoidView extends BaseView
  template: '#void-template'
  className: 'void-page'
  ui:
    button: 'button.void'
    errorSubmit: 'button.error-submit'
  events:
    'click @ui.button': 'returnVoid'
    'click @ui.errorSubmit': 'throwError'
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
  el: '#error'
  template: '#throw-error-template'
  # className: 'throw-error-page modal fade'
  # style: 'top: 100px'
  ui:
    cancel: 'button.cancel'
    return: 'button.return'
    input: 'input.string-value'
    select: 'select.setphrase'
  events:
    'click @ui.cancel': 'cancel'
    'click @ui.return': 'return'
  initialize: ->
    console.log 'error init'
    @model = new Backbone.Model
      key: app.task.get 'key'
    # $(@el).css 'top', '30px'

  onRender: ->
    $("#errorModal").modal 'show'
    # console.log @$el.modal
    # $(@el).modal('show')

  # onBeforeDestroy: ->
  #   console.log arguments
  #   console.log 'before destroy'
  #   $(@el).modal "hide"

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
  Settings: SettingsView
  ThrowError: ThrowErrorView
