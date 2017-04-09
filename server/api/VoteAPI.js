'use strict';

var VoteDBHelper = require('../db/VoteDBHelper');

// Sets up the Votes API for a given express app.
// @param app An express app.
module.exports = function(app) {
	// CREATE VOTE
	app.post('/api/votes', function(req, res) {
		var data = req.body;

		if (!data || !data.user_id || !data.object_id) {
			res.status(400).send('Missing required field.');
			return;
		}

		var user_id = data.user_id;
		var object_id = data.object_id;
		var up = data.up;

		// Check if a vote by this user on this object already exists.
		VoteDBHelper.checkIfExists(user_id, object_id).then(function(exists) {
			if (exists) {
				res.status(400).send('This vote already exists.');
				return;
			}

			// Create a vote.
			VoteDBHelper.createVote(user_id, object_id, up).then(function() {
				// TODO: Modify num_upvotes for the object based on the value of |up|.
				res.status(200).end();
			}).catch(function(err) {
				console.error('Failed to create vote', data, err);
				res.status(500).end();
			});
		}, function(err) {
			console.error('Failed to check if vote exists', data, err);
			res.status(500).end();
		});
	});
};