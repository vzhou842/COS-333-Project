'use strict';

var mongoose = require('mongoose');

var schema = new mongoose.Schema({
	post_id: { $type: String, required: true, unique: true },
	text: { $type: String },
	image_url: { $type: String },
	user_id: { $type: String, required: true },
	timestamp: { $type: Date },
	loc: {
		type: { $type: String, default: 'Point' },
		coordinates: [Number], // [long, lat]
	},
	radius: { $type: Number, default: 5000 }, // meters
	num_upvotes: { $type: Number, default: 0 },
	num_comments: { $type: Number, default: 0 },
	is_deleted: { $type: Boolean, default: false},
}, { typeKey: '$type' });

schema.index({ loc: '2dsphere', radius: -1 });

module.exports = mongoose.model('Post', schema);