'use strict';

var express = require('express');

var app = express();

// Start listening.
var port = process.env.PORT || 8080;
var server = app.listen(port);
console.log('Server listening on port ' + port);