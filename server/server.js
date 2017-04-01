'use strict';

var express = require('express');
var mongoose = require('mongoose');
var db = require('./db');

var app = express();

// Start listening.
var port = process.env.PORT || 8080;
var server = app.listen(port);
console.log('Server listening on port ' + port);