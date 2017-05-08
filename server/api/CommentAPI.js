'use strict';

var CommentDBHelper = require('../db/CommentDBHelper');
var PostDBHelper = require('../db/PostDBHelper');
var db = require('../db/db');
var APIUtils = require('./APIUtils');

// Sets up the Comments API for a given express app.
// @param app An express app.
module.exports = function(app) {
	// CREATE COMMENT
	app.post('/api/comments', function(req, res) {
		var data = req.body;

		if (!data || !data.text || !data.user_id || !data.post_id) {
			APIUtils.invalidRequest(res, JSON.stringify(req.body));
			return;
		}

		CommentDBHelper.createComment({
			text: data.text,
			user_id: data.user_id,
			post_id: data.post_id
		}).then(function() {
			return PostDBHelper.updateComments(data.post_id);
		}).then(function() {
			res.status(200).end();
		}, function(err) {
			console.error('Failed to create comment and update num_comments', data, err);
			res.status(500).end();
		});
	});

	// GET NEW COMMENTS
	// All params are query params.
	// @param post_id The post id.
	app.get('/api/comments/new', function(req, res) {
		var post_id = req.query.post_id;

		if (!post_id) {
			APIUtils.invalidRequest(res, JSON.stringify(req.query));
			return;
		}

		CommentDBHelper.getNewComments(post_id).then(function(comments) {
			res.status(200).send(comments);
		}, function(err) {
			console.error('Failed to get new comments', err);
			res.status(500).end();
		});
	});
};