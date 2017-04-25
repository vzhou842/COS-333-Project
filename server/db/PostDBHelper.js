'use strict';

var Post = require('./models/Post');
var Utils = require('../Utils');
var geolib = require('geolib');

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
	data.post_id = Utils.genPostID();
	data.timestamp = new Date();
	return (new Post(data)).save();
}

function _postsByTimestamp(a, b) {
	return b.timestamp.getTime() - a.timestamp.getTime();
}

var MS_PER_HOUR = 60*60*1000;
function _hot(post) {
	var up = post.num_upvotes;
	var timeFactor = Math.pow(2 + (Date.now() - post.timestamp.getTime()) / MS_PER_HOUR, 1.25);
	return up > 0 ? (up / timeFactor) : (up * timeFactor);
}
function _postsByHot(a, b) {
	return _hot(b) - _hot(a);
}

var ONE_WEEK_MS = 7*24*60*60*1000;
var radiusSort = { radius: -1 };
var newSort = { timestamp: -1 };
function getPosts(long, lat, sort) {
	var sortByNew = sort === 'new';

	// Only ever show posts within the past week.
	var timeFilter = { timestamp: { $gt: new Date(Date.now() - ONE_WEEK_MS) }};

	return Promise.all([
		_postsNear(long, lat, 10000, 120, timeFilter, sortByNew ? newSort : radiusSort), // Up to 120 posts in the local area (10km)
		_postsNear(long, lat, 150000, 50, timeFilter, radiusSort), // Up to 50 posts in the state area (150km)
		_postsNear(long, lat, 500000, 15, timeFilter, radiusSort), // Up to 15 posts in the regional area (500km)
		Post.find(timeFilter).sort(radiusSort).limit(15).lean().exec(), // Up to 15 posts from anywhere
	]).then(function(results) {
		var allPosts = results[0].concat(results[1]).concat(results[2]).concat(results[3]);

		// Remove duplicate posts.
		allPosts = allPosts.filter(function(post, i) {
			for (var index = 0; index < i; index++) {
				if (allPosts[index].post_id === post.post_id) {
					return false;
				}
			}
			return true;
		});

		// Filter out posts that cannot reach this location.
		allPosts = allPosts.filter(function(post) {
			var dist = geolib.getDistance(
				{latitude: lat, longitude: long},
				{latitude: post.loc.coordinates[1], longitude: post.loc.coordinates[0]}
			);
			return post.radius >= dist;
		});

		// Sort and return at most 100 posts.
		return allPosts.sort(sortByNew ? _postsByTimestamp : _postsByHot).slice(0, 100);
	});
}

// Helper function for creating queries to find posts near a point.
// @param radius Specified in meters.
// @param filter Optional
// @param sort Optional
function _postsNear(long, lat, radius, limit, filter, sort) {
	return Post.find(filter).where('loc').near({
		center: { type: 'Point', coordinates: [long, lat] },
		maxDistance: radius,
	}).sort(sort).limit(limit).lean().exec();
}

// @param delta The change in num_upvotes to apply.
function updateVotes(post_id, delta) {
	return Post.update(
		{ post_id: post_id },
		{ $inc: {num_upvotes: delta} }
	).exec();
}

function updateComments(post_id) {
	return Post.update(
		{ post_id: post_id },
		{ $inc: {num_comments: 1} }
	).exec();
}

function checkIfValid(post_id) {
	return Post.count({ post_id: post_id, num_upvotes: {$gt: -5} }).then(function(count) {
		return count > 0;
	});
}

module.exports = {
	createPost: createPost,
	getPosts: getPosts,
	updateVotes: updateVotes,
	checkIfValid: checkIfValid,
};