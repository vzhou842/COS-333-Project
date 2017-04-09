'use strict';

/*
 * This is the main database file.
 * It initializes the database connection and also contains some db methods.
 * Most db methods are in DBHelper files in this directory.
 */

var mongoose = require('mongoose');
var Utils = require('../Utils');

// Setup the database connection.
// We don't care that this URL is in the codebase because it's the sandbox development one.
// In a production scenario we would use an env var here instead.
mongoose.connect(
	'mongodb://robindbuser:robindbpass@ds147520.mlab.com:47520/robin-db'
);
mongoose.connection.on('error', function(e) {
	console.error('MongoDB connection error!', e);
});
mongoose.connection.once('open', function(callback) {
	console.log('MongoDB connection opened.');
});

// ------

module.exports = {
};