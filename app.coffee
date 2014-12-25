'use strict'

express = require 'express'
path = require 'path'
bodyParser = require 'body-parser'

config = port: process.env.PORT or 8931
app = express()

app.disable 'X-powered-by'
app.use express.static path.resolve __dirname, 'public'
app.use bodyParser.urlencoded extended: true

http = require('http').Server app
http.listen config.port
