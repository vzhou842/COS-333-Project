'use strict';

var PostDBHelper = require('../db/PostDBHelper');
var APIUtils = require('./APIUtils');
var multer = require('multer');
var upload = multer({ limits: { fileSize: 10000000 } }); // limit uploads to 10 MB.
var gcs = require('@google-cloud/storage')({
	projectId: 'hallowed-moment-163600.appspot.com',
	keyFilename: './Robin-3aee5e1d90eb.json',
});
var shortid = require('shortid');

var BUCKET_NAME = 'hallowed-moment-163600.appspot.com';
var bucket = gcs.bucket(BUCKET_NAME);

function sendUploadToGCS(req, res, next) {
	if (!req.file) {
		return next();
	}

	var filename = 'img-' + shortid();
	var file = bucket.file(filename);

	var stream = file.createWriteStream({
		metadata: {
			contentType: req.file.mimetype,
		},
		gzip: true,
	});

	stream.on('error', function(err) {
		console.error('Error uploading image to GCS', err);
		res.status(500).end();
	});

	stream.on('finish', function() {
		console.log('Uploading image to GCS finished in ' + (Date.now() - upload_start) + 'ms.');
		req.file.cloud_storage_url = 'https://storage.googleapis.com/' + BUCKET_NAME + '/' + filename;
		next();
	});

	stream.end(req.file.buffer);
	var upload_start = Date.now();
}

// Sets up the Posts API for a given express app.
// @param app An express app.
module.exports = function(app) {
	// CREATE POST
	app.post('/api/posts', upload.single('img'), sendUploadToGCS, function(req, res) {
		var data = req.body;
		var img_url = req.file ? req.file.cloud_storage_url : undefined;

		if (!data || (!data.text && !img_url) || !data.user_id || isNaN(data.lat) || isNaN(data.long)) {
			APIUtils.invalidRequest(res);
			return;
		}

		PostDBHelper.createPost({
			text: data.text,
			image_url: img_url,
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