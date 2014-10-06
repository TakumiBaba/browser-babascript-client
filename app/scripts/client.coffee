LindaAdapter = require 'babascript-linda-adapter'
Client = require 'babascript-client'

adapter = new LindaAdapter 'http://babascript-linda.herokuapp.com', {port: 80}
client = new Client "takumibaba", adapter: adapter

module.exports = client