'use strict';

var PostDBHelper = require('../db/PostDBHelper');
var APIUtils = require('./APIUtils');
var multer = require('multer');
var upload = multer({ limits: { fileSize: 10000000 } }); // limit uploads to 10 MB.

// Sets up the Posts API for a given express app.
// @param app An express app.
module.exports = function(app) {
	// CREATE POST
	app.post('/api/posts', upload.single('img'), function(req, res) {
		var data = req.body;
		var img_file = req.file;

		if (!data || (!data.text && !img_file) || !data.user_id || isNaN(data.lat) || isNaN(data.long)) {
			APIUtils.invalidRequest(res);
			return;
		}

		// TODO: save the uploaded file (if any) to Google Cloud Storage.

		PostDBHelper.createPost({
			text: data.text,
			image_url: '', //TODO
			user_id: data.user_id,
			loc: {
				coordinates: [parseFloat(data.long), parseFloat(data.lat)],
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