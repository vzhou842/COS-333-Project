'use strict';

var VoteDBHelper = require('../db/VoteDBHelper');
var db = require('../db/db');
var APIUtils = require('./APIUtils');

// Sets up the Votes API for a given express app.
// @param app An express app.
module.exports = function(app) {
	// CREATE VOTE
	app.post('/api/votes', function(req, res) {
		var data = req.body;

		if (!data || !data.user_id || !data.object_id) {
			APIUtils.invalidRequest(res);
			return;
		}

		var user_id = data.user_id;
		var object_id = data.object_id;
		var up = data.up;

		// Check if:
		// - the same vote exists, and if a vote by this user on this object already exists.
		// - this object actually exists.
		Promise.all([
			VoteDBHelper.checkIfSameExists(user_id, object_id, up),
			VoteDBHelper.checkIfExists(user_id, object_id),
			db.checkIfObjectExists(object_id),
		]).then(function(results) {
			var sameExists = results[0];
			var voteExists = results[1];
			var objectExists = results[2];

			if (!objectExists) {
				APIUtils.invalidRequest(res, 'This object does not exist.');
				return;
			}

			if (sameExists) {
				VoteDBHelper.removeVote(user_id, object_id).then(function() {
					return db.updateVotesForObject(object_id, -1);
				}).then(function() {
					res.status(200).send({ message: "Removed vote."});
				}, function(err) {
					console.error('Failed to remove vote and update num_upvotes', data, err);
					res.status(500).end();
				});
			}
			else {
				if (voteExists) {
					VoteDBHelper.updateVote(user_id, object_id, up).then(function() {
						return db.updateVotesForObject(object_id, up ? 2 : -2); 
					}).then(function() {
						res.status(200).send({ message: "Updated vote."});
					}, function(err) {
						console.error('Failed to update vote and update num_upvotes', data, err);
						res.status(500).end();
					});
				}
				else {
					VoteDBHelper.createVote(user_id, object_id, up).then(function() {
						return db.updateVotesForObject(object_id, up ? 1 : -1);
					}).then(function() {
						res.status(200).send({ message: "Created vote."});
					}, function(err) {
						console.error('Failed to create vote and update num_upvotes', data, err);
						res.status(500).end();
					});
				}
			}
		}, function(err) {
			console.error('Failed to check if vote exists', data, err);
			res.status(500).end();
		});
	});
};