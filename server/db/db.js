'use strict';

/*
 * This is the main database file.
 * It initializes the database connection and also contains some generic db methods.
 * Most db methods are in DBHelper files in this directory.
 */

var mongoose = require('mongoose');
var Utils = require('../Utils');
var PostDBHelper = require('./PostDBHelper');

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

// @param object_id Either a post_id or a comment_id.
// @param delta The change in num_upvotes to apply.
function updateVotesForObject(object_id, delta) {
	if (Utils.isPostID(object_id)) {
		return PostDBHelper.updateVotes(object_id, delta);
	} else if (Utils.isCommentID(object_id)) {
		// TODO
	}
}

function checkIfObjectExists(object_id) {
	if (Utils.isPostID(object_id)) {
		return PostDBHelper.checkIfExists(object_id);
	} else if (Utils.isCommentID(object_id)) {
		// TODO
	}
}

module.exports = {
	updateVotesForObject: updateVotesForObject,
	checkIfObjectExists: checkIfObjectExists,
};