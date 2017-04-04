'use strict';

var Post = require('./models/Post');
var shortid = require('shortid');

// Sets up the Posts API for a given express app.
// @param app An express app.
module.exports = function(app) {
	app.post('/api/posts', function(req, res) {
		var data = req.body;

		if ((!data.text && !data.image_url) || !data.user_id) {
			res.status(400).send('Missing required field.');
			return;
		}

		var post = new Post({
			post_id: 'p' + shortid(),
			text: data.text,
			image_url: data.image_url,
			user_id: data.user_id,
			timestamp: new Date(),
			loc: undefined, //TODO
		});

		post.save().then(function(savedPost) {
			res.status(200).end();
		}, function(err) {
			console.error('Failed to save post', err);
			res.status(500).end();
		});
	});
};