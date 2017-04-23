'use strict';

var Vote = require('./models/Vote');

// Resolves with a bool depending on whether a vote for the supplied params already exists.
function checkIfExists(user_id, object_id) {
	return Vote.count({ user_id: user_id, object_id: object_id })
		.then(function(count) {
			return count > 0;
		});
}

// Resolves with a bool depending on whether a vote for the supplied params already exists.
function checkIfSameExists(user_id, object_id, up) {
	return Vote.count({ user_id: user_id, object_id: object_id, up: up })
		.then(function(count) {
			return count > 0;
		});
}

function createVote(user_id, object_id, up) {
	var v = new Vote({
		user_id: user_id,
		object_id: object_id,
		up: !!up,
	});
	return v.save();
}

// Removes a vote.
function removeVote(user_id, object_id) {
	return Vote.remove(
		{ user_id: user_id, object_id: object_id }
	).exec();
}

// Updates vote up count.
function updateVote(user_id, object_id, up) {
	return Vote.update(
		{ up: up }
	).exec();
}

module.exports = {
	checkIfExists: checkIfExists,
	checkIfSameExists: checkIfSameExists,
	createVote: createVote,
	removeVote: removeVote,
	updateVote: updateVote,
}