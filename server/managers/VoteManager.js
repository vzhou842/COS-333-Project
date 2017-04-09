'use strict';

var Vote = require('../models/Vote');

// Resolves with a bool depending on whether a vote for the supplied params already exists.
function checkIfExists(user_id, object_id) {
	return Vote.count({ user_id: user_id, object_id: object_id })
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

module.exports = {
	checkIfExists: checkIfExists,
	createVote: createVote,
}