trigger BlockUnauthorisedChatterPosts on FeedItem (before insert) {
    List<FeedItem> newChatterPosts = (List<FeedItem>)trigger.new;
    ChatterPostsValidations.validateUserCanPostToGroup(newChatterPosts);
}