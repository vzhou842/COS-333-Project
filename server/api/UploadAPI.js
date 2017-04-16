'use strict';

var multer  = require('multer');
var upload = multer({ limits: { fileSize: 50000000 } }); // limit uploads to 50 MB.

// Sets up the Upload API for a given express app.
// @param app An express app.
module.exports = function(app) {
	app.post('/api/upload', upload.single('img'), function(req, res) {
		var file = req.file;
		// TODO: save the uploaded file to Google Cloud Storage and respond with the image_url.
		console.log(file);
		res.status(200).send({
			image_url: 'TODO',
		});
	});
};