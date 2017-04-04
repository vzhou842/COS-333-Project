'use strict';

var mongoose = require('mongoose');

var schema = new mongoose.Schema({
	post_id: { $type: String, required: true, unique: true },
	text: { $type: String },
	image_url: { $type: String },
	user_id: { $type: String, required: true },
	timestamp: { $type: Date },
	loc: {
		type: String,
		coordinates: [Number],
	},
	radius: { $type: Number },
	num_upvotes: { $type: Number, default: 0 },
	num_comments: { $type: Number, default: 0 },
}, { typeKey: '$type' });

// TODO: add indicies.

module.exports = mongoose.model('Post', schema);