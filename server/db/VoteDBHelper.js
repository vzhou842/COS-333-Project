'use strict';

var Vote = require('./models/Vote');

function getVote(user_id, object_id) {
	return Vote.findOne({ user_id: user_id, object_id: object_id });
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
		{ user_id: user_id, object_id: object_id, up: up }
	).exec();
}

module.exports = {
	getVote: getVote,
	createVote: createVote,
	removeVote: removeVote,
	updateVote: updateVote,
}