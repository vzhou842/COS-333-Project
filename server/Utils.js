'use strict';

var shortid = require('shortid');

var POST_IDENTIFIER = 'p';
var COMMENT_IDENTIFIER = 'c';

module.exports = {
	genPostID: function() {
		return POST_IDENTIFIER + shortid();
	},
	genCommentID: function() {
		return COMMENT_IDENTIFIER + shortid();
	},
	isPostID: function(id) {
		return id[0] === POST_IDENTIFIER;
	},
	isCommentID: function(id) {
		return id[0] === COMMENT_IDENTIFIER;
	},
};