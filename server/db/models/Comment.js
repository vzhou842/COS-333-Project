'use strict';

var mongoose = require('mongoose');

var schema = new mongoose.Schema({
	comment_id: { type: String, required: true, unique: true },
	post_id: { type: String, required: true },
	text: { type: String, required: true },
	user_id: { type: String, required: true },
	timestamp: { type: Date },
	num_upvotes: { type: Number, default: 0 },
});

schema.index({ post_id: 1, timestamp: 1 });

module.exports = mongoose.model('Comment', schema);