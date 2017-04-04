'use strict';

var mongoose = require('mongoose');

var schema = new mongoose.Schema({
	user_id: { type: String, required: true },
	object_id: { type: String, required: true },
	up: { type: Boolean, required: true },
});

schema.index({ user_id: 1, object_id: 1 });

module.exports = mongoose.model('Vote', schema);