animated	        Boolean	    Whether the image is animated.
aspect_ratio	    Float	    The image's width divided by its height.
comment_count	    Integer	    The number of comments made on the image.
created_at	        RFC3339 datetime	The creation time, in UTC, of the image.
deletion_reason	    String	    The hide reason for the image, or null if none provided. This will only have a value on images which are deleted for a rule violation.
description	        String	    The image's description.
downvotes	        Integer	    The number of downvotes the image has.
duplicate_of	    Integer	    The ID of the target image, or null if none provided. This will only have a value on images which are merged into another image.
duration	        Float	    The number of seconds the image lasts, if animated, otherwise .04.
faves	            Integer	    The number of faves the image has.
first_seen_at	    RFC3339datetime	The time, in UTC, the image was first seen (before any duplicate merging).
format	            String	    The file extension of the image. One of "gif", "jpg", "jpeg", "png", "svg", "webm".
height	            Integer	    The image's height, in pixels.
hidden_from_users	Boolean	    Whether the image is hidden. An image is hidden if it is merged or deleted for a rule violation.
id	                Integer	    The image's ID.
intensities	        Object	    Optional object of internal image intensity data for deduplication purposes. May be null if intensities have not yet been generated.
mime_type	        String	    The MIME type of this image. One of "image/gif", "image/jpeg", "image/png", "image/svg+xml", "video/webm".
name	            String	    The filename that the image was uploaded with.
orig_sha512_hash	String	    The SHA512 hash of the image as it was originally uploaded.
processed	        Boolean	    Whether the image has finished optimization.
representations	    Object	    A mapping of representation names to their respective URLs. Contains the keys "full", "large", "medium", "small", "tall", "thumb", "thumb_small", "thumb_tiny".
score	            Integer	    The image's number of upvotes minus the image's number of downvotes.
sha512_hash	        String	    The SHA512 hash of this image after it has been processed.
size	            Integer	    The number of bytes the image's file contains.
source_url	        String	    The current source URL of the image.
spoilered	        Boolean	    Whether the image is hit by the current filter.
tag_count	        Integer	    The number of tags present on the image.
tag_ids	            Array	    A list of tag IDs the image contains.
tags	            Array	    A list of tag names the image contains.
thumbnails_generated	Boolean	Whether the image has finished thumbnail generation. Do not attempt to load images from view_url or representations if this is false.
updated_at	        RFC3339 datetime	The time, in UTC, the image was last updated.
uploader	        String	    The image's uploader.
uploader_id	        Integer	    The ID of the image's uploader. null if uploaded anonymously.
upvotes	            Integer	    The image's number of upvotes.
view_url	        String	    The image's view URL, including tags.
width	            Integer	    The image's width, in pixels.
wilson_score	    Float	    The lower bound of the Wilson score interval for the image, based on its upvotes and downvotes, given a z-score corresponding to a confidence of 99.5%.
