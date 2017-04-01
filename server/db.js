'use strict';

var mongoose = require('mongoose');

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