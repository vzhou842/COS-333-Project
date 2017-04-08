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


### ```GET /api/posts/new```

Gets all new posts.

The request response will be a JSON array of Posts, where each Post matches the following format:
```javascript
{
    "post_id": "pBJgkqteag",
    "text": "test post",
    "user_id": "fake user",
    "timestamp": "2017-04-04T02:50:00.506Z",
    "num_comments": 0,
    "num_upvotes": 0,
    "radius": 5,
    "loc": {
        "coordinates": [-1.522, 2.453], // [latitude, longitude]
    },
}
```

Returns status code ```200``` on success and ```500``` if an error occurred.

