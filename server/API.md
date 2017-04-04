# Robin API Reference

The base URL for the API is: https://hallowed-moment-163600.appspot.com

All URLs below will be relative URLs with respect to this base URL.

## Posts API

### ```POST /api/posts```

Creates a post.

The request body should be JSON matching the following format:
```javascript
{
    text: "Post text, if any",
    image_url: "https://website.com/url-to-the-image-if-any.png",
    user_id: "the_users_id",
    lat: -5.1244, // latitude
    long: 2.351, // longitude
}
```

Returns status code ```200``` on success, ```400``` if the request was invalid, and ```500``` if an error occurred.
