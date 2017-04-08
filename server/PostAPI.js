'use strict';

var Post = require('./models/Post');
var shortid = require('shortid');

// Removes private / unneeded fields from a Post object and returns it.
function cleanPost(post) {
	delete post._id;
	delete post.__v;
	return post;
}

// Cleans all posts in the array |posts| and returns it.
function cleanAllPosts(posts) {
	return posts.map(cleanPost);
}

// Sets up the Posts API for a given express app.
// @param app An express app.
module.exports = function(app) {
	// Create Post
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

	// Get New Posts
	app.get('/api/posts/new', function(req, res) {
		Post.find().sort({ timestamp: -1 }).limit(100).lean().exec().then(cleanAllPosts).then(function(posts) {
			res.status(200).send(posts);
		}, function(err) {
			console.error('Failed to get new posts', err);
			res.status(500).end();
		});
	});
};