'use strict';

var PostDBHelper = require('../db/PostDBHelper');
var APIUtils = require('./APIUtils');

// Sets up the Posts API for a given express app.
// @param app An express app.
module.exports = function(app) {
	// CREATE POST
	app.post('/api/posts', function(req, res) {
		var data = req.body;

		if (!data || (!data.text && !data.image_url) || !data.user_id || !Number.isFinite(data.lat) || !Number.isFinite(data.long)) {
			APIUtils.invalidRequest(res);
			return;
		}

		PostDBHelper.createPost({
			text: data.text,
			image_url: data.image_url,
			user_id: data.user_id,
			loc: {
				coordinates: [data.long, data.lat],
			}
		}).then(function(savedPost) {
			res.status(200).end();
		}, function(err) {
			console.error('Failed to save post', err);
			res.status(500).end();
		});
	});

	// GET NEW POSTS
	// All params are query params.
	// @param long The user's longitude.
	// @param lat The user's latitude.
	app.get('/api/posts/new', function(req, res) {
		var long = parseFloat(req.query.long);
		var lat = parseFloat(req.query.lat);

		if (!Number.isFinite(long) || !Number.isFinite(lat)) {
			APIUtils.invalidRequest(res);
			return;
		}

		PostDBHelper.getNewPosts(long, lat).then(function(posts) {
			res.status(200).send(posts);
		}, function(err) {
			console.error('Failed to get new posts', err);
			res.status(500).end();
		});
	});
};