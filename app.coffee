'use strict'

express = require 'express'
path = require 'path'
debug = require('debug')('babascript:client:browser')

config = port: process.env.PORT or 8931

bodyParser = require 'body-parser'
app = express()

app.disable 'X-powered-by'
app.use express.static path.resolve __dirname, 'public'
app.use bodyParser.urlencoded extended: true

http = require('http').Server app
http.listen config.port, ->
  debug config.port
