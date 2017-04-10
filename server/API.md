# Robin API Reference

The base URL for the API is: https://hallowed-moment-163600.appspot.com

All URLs below will be relative URLs with respect to this base URL.

## Status Codes

API calls return status code ```200``` on success, ```400``` if the request was invalid, and ```500``` if a server error occurred.

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
        "type": "Point",
        "coordinates": [-1.522, 2.453], // [longitude, latitude]
    },
}
```

## Votes API

### ```POST /api/votes```

Creates a vote (either an upvote or a downvote).

The request body should be JSON matching the following format:
```javascript
{
    user_id: "fake user",
    object_id: "either post_id or comment_id",
    up: true, // or false
}
```

## Comments API

### ```POST /api/comments```

Creates a comment.

The request body should be JSON matching the following format:
```javascript
{
    text: "Comment text",
    user_id: "the_users_id",
    post_id: "the_posts_id"
}
```


### ```GET /api/posts/new```

Gets all new comments.

The request response will be a JSON array of Posts, where each Post matches the following format:
```javascript
{
    "comment_id": "cAKDkqtmel"
    "post_id": "pBJgkqteag",
    "text": "test comment",
    "user_id": "fake user",
    "timestamp": "2017-04-04T02:50:00.506Z",
    "num_upvotes": 0,
}
```
