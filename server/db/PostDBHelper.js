'use strict';

var Post = require('./models/Post');
var Utils = require('../Utils');
var geolib = require('geolib');
var request = require('request');

// This is bad practice but since this is just a school project and we're too lazy to set it up
// as an env var we're going to just hardcode this here.
var GMAPS_API_KEY = 'AIzaSyCRr2EA72-WRe8Bbzq4nVQY7OYwBxo0Oe0';

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
	var accept, reject;
	var promise = new Promise(function(a, r) {
		accept = a;
		reject = r;
	});

	// Reverse Geocode the lat/long to get a city name.
	var lat = data.loc.coordinates[1];
	var long = data.loc.coordinates[0];
	request('https://maps.googleapis.com/maps/api/geocode/json?latlng=' + lat + ',' + long + '&result_type=locality&key=' + GMAPS_API_KEY, function(err, response, body) {
		var loc_name;
		if (!err && body) {
			body = JSON.parse(body);
			if (body.results && body.results.length) {
				var result = body.results[0];
				if (result.address_components && result.address_components.length) {
					var c = result.address_components[0];
					loc_name = c.short_name || c.long_name;
				}
			}
		}

		// Save the post.
		data.loc.name = loc_name;
		data.post_id = Utils.genPostID();
		data.timestamp = new Date();
		(new Post(data)).save().then(accept, reject);
	});
	return promise;
}

function deletePost(post_id) {
	return Post.update(
		{ post_id: post_id },
		{ is_deleted: true }
	).exec();
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
	var timeFilter = { timestamp: { $gt: new Date(Date.now() - ONE_WEEK_MS) },
					   num_upvotes: { $gt: -5 },
					   is_deleted: { $ne: true },
					 };

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

// @param d_upvotes The change in the # of upvotes.
// @param d_downvotes The change in the # of downvotes.
// @param vote_coords The [long, lat] of the vote.
function updateVotes(post_id, d_upvotes, d_downvotes, vote_coords) {
	return Post.findOne({ post_id: post_id }).then(function(post) {
		if (!post) {
			return Promise.reject('Post not found.');
		}

		// Update # upvotes on this post.
		post.num_upvotes += d_upvotes - d_downvotes;

		// Update the radius of this post based on d_upvotes.
		if (d_upvotes !== 0) {
			post.radius += d_upvotes * deltaRadiusForVote(post.loc.coordinates, vote_coords);
		}

		return post.save();
	});
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

// Returns how much radius a post should gain from a given upvote.
// The most a single upvote can increase radius is 1000m.
// Multiplier based on distance in km: f(x) = 0.2  + 0.8 / (1 + 2^(5 - x))
// Coordinates are always [long, lat].
function deltaRadiusForVote(post_coords, vote_coords) {
	var meters = geolib.getDistance(
		{ latitude: post_coords[1], longitude: post_coords[0] },
		{ latitude: vote_coords[1], longitude: vote_coords[0] }
	);
	var multiplier = 0.2 + 0.8 / (1 + Math.pow(2, 5 - meters/1000));
	return multiplier * 1000;
}

module.exports = {
	createPost: createPost,
	getPosts: getPosts,
	updateVotes: updateVotes,
	updateComments: updateComments,
	checkIfValid: checkIfValid,
	deletePost: deletePost,
};