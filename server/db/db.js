'use strict';

/*
 * This is the main database file.
 * It initializes the database connection and also contains some generic db methods.
 * Most db methods are in DBHelper files in this directory.
 */

var mongoose = require('mongoose');
var Utils = require('../Utils');
var PostDBHelper = require('./PostDBHelper');
var CommentDBHelper = require('./CommentDBHelper');

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
// @param d_upvotes The change in the # of upvotes.
// @param d_downvotes The change in the # of downvotes.
// @param vote_coords The [long, lat] of the vote.
function updateVotesForObject(object_id, d_upvotes, d_downvotes, vote_coords) {
	if (Utils.isPostID(object_id)) {
		return PostDBHelper.updateVotes(object_id, d_upvotes, d_downvotes, vote_coords);
	} else if (Utils.isCommentID(object_id)) {
		return CommentDBHelper.updateVotes(object_id, d_upvotes - d_downvotes);
	}
}

function checkIfObjectValid(object_id) {
	if (Utils.isPostID(object_id)) {
		return PostDBHelper.checkIfValid(object_id);
	} else if (Utils.isCommentID(object_id)) {
		return CommentDBHelper.checkIfValid(object_id);
	}
}

module.exports = {
	updateVotesForObject: updateVotesForObject,
	checkIfObjectValid: checkIfObjectValid,
};