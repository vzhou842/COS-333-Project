'use strict';

/*
 * This is the main test file.
 * Tests are run using Mocha: https://mochajs.org/
 */

var assert = require('assert');
var Utils = require('../Utils');

describe('Utils', function() {
	it('A generated post_id should pass isPostID()', function() {
		assert(Utils.isPostID(Utils.genPostID()));
	});
	it('A generated comment_id should pass isCommentID()', function() {
		assert(Utils.isCommentID(Utils.genCommentID()));
	});
});