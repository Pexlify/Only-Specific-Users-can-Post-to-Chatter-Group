# Only-Specific-Users-can-Post-to-Chatter-Group

By default Salesforce only allows you to make a chatter group public or private. If you decide to make a chatter group private, any users who are not a member of that group cannot see or add posts to that group.

However, sometimes we would like to allow users to see posts in a group but not to add posts to it.

We can achieve this by creating a simple custom settings, user groups and a simple trigger code.

The custom settings would link a chatter group to a public users group. Then, only member of this users group would be able to post chatter posts to that chatter group. This will also allow easy administration to add/remove users from the authorised list of users.

When a user will try to post to a group they’re not authorised to do so they will see the following error message that will prevent them from adding a chatter post:

We decided to name our custom settings list object as Chatter_Group_Authorized_Users__c. We added 2 text fields to it called Chatter_Group_Name__c and Group_Name_Of_Authorized_Users__c.

Then we added a trigger code on the FeedItem object.

Most of the logic is maintained in a dedicated class. That logic is check if the chatter post is posted under a group, if the chatter group has a group of authorized users associated with it and if the current is a member of that group.

You can see how we do the SOQL queries only if they’re necessary.

First we check if the new chatter posts were added to chatter groups. Only then we check if there are any settings associated with those chatter groups and at last we get the list of users from the associated groups.

We then go over the list of new chatter posts and make sure the current user can add each one of them.