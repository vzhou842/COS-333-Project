'use strict';

var Post = require('../models/Post');
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

// @param data Should contain all necessary user-specified fields for the post.
function createPost(data) {
	data.post_id = 'p' + shortid();
	data.timestamp = new Date();
	return (new Post(data)).save();
}

function getNewPosts(long, lat) {
	return Post.find().where('loc').near({
		center: { type: 'Point', coordinates: [long, lat] },
		maxDistance: 5000,
	}).sort({ timestamp: -1 }).limit(100).lean().exec().then(cleanAllPosts);
}

module.exports = {
	createPost: createPost,
	getNewPosts: getNewPosts,
};