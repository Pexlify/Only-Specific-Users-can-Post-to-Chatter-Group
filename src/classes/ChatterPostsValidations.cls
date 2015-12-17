public with sharing class ChatterPostsValidations {

    private static Map<Id,CollaborationGroup> chatterGroups;
    private static Map<String, String> chatterGroupNameToAuthorisedUsersGroupName;
    private static List<Group> groupsAndTheirMembers;

    public static void validateUserCanPostToGroup(List<FeedItem> newChatterPosts){
        chatterGroups = getChatterGroups(newChatterPosts);
        if(!chatterGroups.isEmpty()){
            getChatterGroupNameToAuthorisedUsersGroupName();
            if(!chatterGroupNameToAuthorisedUsersGroupName.isEmpty()){
                getGroupsAndTheirMembers();
                for(FeedItem newChatterPost : newChatterPosts){
                    if(userCantCreateChatterPost(newChatterPost)){
                        newChatterPost.addError('You do not have permissions to post to this chatter group');
                    }
                }
            }
        }
    }

    private static Map<Id,CollaborationGroup> getChatterGroups(List<FeedItem> newChatterPosts){
        Set<Id> chatterGroupIds = new Set<Id>();
        for(FeedItem newChatterPost : newChatterPosts){
            chatterGroupIds.add(newChatterPost.ParentId);
        }
        return new Map<Id,CollaborationGroup>([SELECT Id, Name FROM CollaborationGroup WHERE Id IN :chatterGroupIds]);
    }

    private static void getChatterGroupNameToAuthorisedUsersGroupName(){
        chatterGroupNameToAuthorisedUsersGroupName = new Map<String, String>();
        for(Chatter_Group_Authorized_Users__c c : [SELECT Chatter_Group_Name__c, Group_Name_Of_Authorized_Users__c FROM Chatter_Group_Authorized_Users__c]){
            chatterGroupNameToAuthorisedUsersGroupName.put(c.Chatter_Group_Name__c, c.Group_Name_Of_Authorized_Users__c);
        }
    }

    private static void getGroupsAndTheirMembers(){
        groupsAndTheirMembers = [SELECT Name, (SELECT UserOrGroupId FROM GroupMembers)
                                FROM Group
                                WHERE Type != 'Queue' AND Name IN :chatterGroupNameToAuthorisedUsersGroupName.values()];
    }

    private static Boolean userCantCreateChatterPost(FeedItem newChatterPost){
        if(chatterGroups.containsKey(newChatterPost.ParentId)){
            CollaborationGroup chatterGroup = chatterGroups.get(newChatterPost.ParentId);
            if(chatterGroupNameToAuthorisedUsersGroupName.containsKey(chatterGroup.Name)){
                String usersGroupName = chatterGroupNameToAuthorisedUsersGroupName.get(chatterGroup.Name);
                return userIsntMemberOfGroup(usersGroupName);
            }
        }
        return false;
    }

    private static Boolean userIsntMemberOfGroup(String usersGroupName){
        for(Group g : groupsAndTheirMembers){
            if(g.Name == usersGroupName){
                for(GroupMember gm : g.GroupMembers){
                    if(UserInfo.getUserId() == gm.UserOrGroupId){
                        return false;
                    }
                }
            }
        }
        return true;
    }
}