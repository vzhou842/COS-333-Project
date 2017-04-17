'use strict';

var express = require('express');

// Setup the database.
var db = require('./db/db');

// Use native promises for mongoose.
require('mongoose').Promise = global.Promise;

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
require('./api/PostAPI')(app);

// Setup the Votes API.
require('./api/VoteAPI')(app);

// Setup the Comments API.
require('./api/CommentAPI')(app);
