Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
app = require './app'
_ = require 'lodash'

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
    setTimeout ->
      app.task.clear()
      app.client.returnValue value, option
      app.client.emit 'return_value', value
      window.plugins?.toast?.show "返り値: #{value}", "short", "center"
    , 300

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
  events:
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
    format = @model?.get 'format'
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
    @returnview.reset()
    @returnview.show new viewClass {model: @model}

class NormalView extends BaseView
  template: '#normal-template'
  className: 'normal-page'

class BooleanView extends BaseView
  template: '#boolean-template'
  className: 'boolean-page'
  ui:
    truebutton: 'button.yes-button'
    falsebutton: 'button.no-button'
  events:
    'click @ui.truebutton': 'returntrue'
    'click @ui.falsebutton': 'returnfalse'
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
    button: 'button'
  events:
    'click @ui.button': 'returnString'
    'click @ui.input': 'onFocus'

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
    a: 'a'
  events:
    'click @ui.a': 'returnSelect'
    'click @ui.button': 'returnSelect'
  returnSelect: (e) ->
    value = e.target.id
    @returnValue value

class NumberView extends BaseView
  template: '#number-template'
  className: 'number-page'
  ui:
    form: 'form.number-form'
    input: 'input.number-value'
    button: 'button'
    submit: 'input.submit'
  events:
    'click @ui.button': 'returnNumber'
    'submit @ui.form': 'returnNumber'

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
