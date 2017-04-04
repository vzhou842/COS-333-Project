'use strict';

var express = require('express');
var mongoose = require('mongoose');
var db = require('./db');

var app = express();

// Start listening.
var port = process.env.PORT || 8080;
var server = app.listen(port);
console.log('Server listening on port ' + port);

// Enable a JSON body parser.
app.use(require('body-parser').json({ type: 'application/json' }));

// Setup a debug endpoint.
app.get('/ping', function(req, res) {
	res.status(200).send('pong');
});

// Setup the Posts API.
require('./PostAPI')(app);