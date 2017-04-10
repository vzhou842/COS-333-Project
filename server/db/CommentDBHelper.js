'use strict';

var Comment = require('./models/Comment');
var Utils = require('../Utils');

// @param data Should contain all necessary user-specified fields for the post.
function createComment(data) {
	data.comment_id = Utils.genCommentID();
	data.timestamp = new Date();
	return (new Comment(data)).save();
}

// todo: complete
function getNewComments(post_id) {
	return Comment.find({ 
		'post_id': post_id
	}).sort({ timestamp: -1 }).limit(100).lean().exec().then(cleanAllComments);
}

// Removes private / unneeded fields from a Post object and returns it.
function cleanComment(comment) {
	delete comment._id;
	delete comment.__v;
	return comment;
}

// Cleans all posts in the array |posts| and returns it.
function cleanAllComments(comments) {
	return comments.map(cleanComment);
}

// @param delta The change in num_upvotes to apply.
function updateVotes(comment_id, delta) {
	return Comment.update(
		{ comment_id: comment_id },
		{ $inc: {num_upvotes: delta} }
	).exec();
}

function checkIfExists(comment_id) {
	return Comment.count({ comment_id: comment_id }).then(function(count) {
		return count > 0;
	});
}

module.exports = {
	createComment: createComment,
	getNewComments: getNewComments,
	updateVotes: updateVotes,
	checkIfExists: checkIfExists,
};