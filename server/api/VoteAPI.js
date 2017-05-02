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

		var user_id = data.user_id;
		var object_id = data.object_id;
		var up = data.up;
		var lat = data.lat;
		var long = data.long;

		if (!data || !user_id || !object_id || !Number.isFinite(lat) || !Number.isFinite(long)) {
			APIUtils.invalidRequest(res);
			return;
		}

		var coords = [long, lat];

		console.log('Received ' + (up ? 'up' : 'down') + 'vote for ' + object_id + ' from ' + user_id);

		// Check if:
		// - the same vote exists, and if a vote by this user on this object already exists.
		// - this object actually exists.
		Promise.all([
			VoteDBHelper.getVote(user_id, object_id),
			db.checkIfObjectValid(object_id),
		]).then(function(results) {
			var vote = results[0];
			var objectValid = results[1];

			if (!objectValid) {
				APIUtils.invalidRequest(res, 'This object is not valid.');
				return;
			}

			// Undo an existing vote.
			if (vote && vote.up === !!up) {
				VoteDBHelper.removeVote(user_id, object_id).then(function() {
					return db.updateVotesForObject(object_id, up ? -1 : 0, !up ? -1 : 0, coords);
				}).then(function() {
					res.status(200).send({ message: "Removed vote."});
				}, function(err) {
					console.error('Failed to remove vote and update num_upvotes', data, err);
					res.status(500).end();
				});
			}
			// Change an existing vote.
			else if (vote) {
				VoteDBHelper.updateVote(user_id, object_id, up).then(function() {
					return db.updateVotesForObject(object_id, up ? 1 : -1, !up ? 1 : -1, coords);
				}).then(function() {
					res.status(200).send({ message: "Updated vote."});
				}, function(err) {
					console.error('Failed to update vote and update num_upvotes', data, err);
					res.status(500).end();
				});
			}
			// Create a vote.
			else {
				VoteDBHelper.createVote(user_id, object_id, up).then(function() {
					return db.updateVotesForObject(object_id, up ? 1 : 0, !up ? 1 : 0, coords);
				}).then(function() {
					res.status(200).send({ message: "Created vote."});
				}, function(err) {
					console.error('Failed to create vote and update num_upvotes', data, err);
					res.status(500).end();
				});
			}
		}, function(err) {
			console.error('Failed to check if vote exists', data, err);
			res.status(500).end();
		});
	});
};