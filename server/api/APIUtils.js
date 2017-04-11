'use strict';

module.exports = {
	// @param errString Optional.
	invalidRequest: function(res, errString) {
		res.status(400).send({
			error: errString || 'Invalid request - missing required field.',
		});
	},
};