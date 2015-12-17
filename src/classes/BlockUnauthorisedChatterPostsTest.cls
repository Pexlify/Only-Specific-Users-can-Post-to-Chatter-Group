@isTest
private class BlockUnauthorisedChatterPostsTest {
    static testMethod void userCanAddChatterPostToChatterGroupWhenThereAreNoSettingsTest() {
        SetupData setupData = new SetupData();
        System.runAs(setupData.testingUser) {
            setupData.createtestChatterGroup();
            FeedItem new_chatter_post = new FeedItem(Body ='Some content', ParentId = setupData.testChatterGroup.Id);
            Test.startTest();
                Database.SaveResult insert_chatter_post_result = Database.insert(new_chatter_post, false);
            Test.stopTest();
            System.assertEquals(true, insert_chatter_post_result.isSuccess(), 'Expected user to be able to add chatter post to chatter group when there are no settings');
        }
    }

    static testMethod void userCantAddChatterPostToChatterGroupWhenChatterGroupHasRestrictedUsersListAndCurrentUserIsNotMemberOfTheGroupTest() {
        SetupData setupData = new SetupData();
        System.runAs(setupData.testingUser) {
            setupData.createtestChatterGroup();
            setupData.createTestUsersGroup();
            setupData.createChatterGroupAuthorizedUsersRecord();
            FeedItem new_chatter_post = new FeedItem(Body ='Some content', ParentId = setupData.testChatterGroup.Id);
            Test.startTest();
                Database.SaveResult insert_chatter_post_result = Database.insert(new_chatter_post, false);
            Test.stopTest();
            System.assertEquals(false, insert_chatter_post_result.isSuccess(), 'Expected user to not be able to add chatter post to chatter group when the user is not a member of the group of users for this chatter group');
        }
    }

    static testMethod void userCanAddChatterPostToOtherObjectWhenChatterGroupHasRestrictedUsersListAndCurrentUserIsNotMemberOfTheGroupTest() {
        SetupData setupData = new SetupData();
        System.runAs(setupData.testingUser) {
            setupData.createtestChatterGroup();
            setupData.createTestUsersGroup();
            setupData.createChatterGroupAuthorizedUsersRecord();
            Case testCase = new Case();
            insert testCase;
            FeedItem new_chatter_post = new FeedItem(Body = 'Some content', ParentId = testCase.Id);
            Test.startTest();
                Database.SaveResult insert_chatter_post_result = Database.insert(new_chatter_post, false);
            Test.stopTest();
            System.assertEquals(true, insert_chatter_post_result.isSuccess(), 'Expected user to be able to add chatter post to case');
        }
    }

    static testMethod void userCanAddChatterPostToChatterGroupWhenChatterGroupHasRestrictedUsersListAndCurrentUserIsMemberOfTheGroupTest() {
        SetupData setupData = new SetupData();
        System.runAs(setupData.testingUser) {
            setupData.createtestChatterGroup();
            setupData.createTestUsersGroup();
            setupData.assignUserToTestUsersGroup();
            setupData.createChatterGroupAuthorizedUsersRecord();
            FeedItem new_chatter_post = new FeedItem(Body ='Some content', ParentId = setupData.testChatterGroup.Id);
            Test.startTest();
                Database.SaveResult insert_chatter_post_result = Database.insert(new_chatter_post, false);
            Test.stopTest();
            System.assertEquals(true, insert_chatter_post_result.isSuccess(), 'Expected user to not be able to add chatter post to chatter group when the user is not a member of the group of users for this chatter group');
        }
    }


    private class SetupData{
        public User testingUser;
        public CollaborationGroup testChatterGroup;
        public Group testUsersGroup;

        public SetupData(){
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
            testingUser = new User(Alias = 'jsmith', Email='email@test.com', EmailEncodingKey='UTF-8', LastName='Smith', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName= getRandomString(10) + '@test.com');
            insert testingUser;
        }

        private String getRandomString(Integer length) {
            final String possibleChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
            String randomString = '';
            while (randomString.length() < length) {
               Integer indexRandomChar = Math.mod(Math.abs(Crypto.getRandomInteger()), possibleChars.length());
               randomString += possibleChars.substring(indexRandomChar, indexRandomChar + 1);
            }
           return randomString;
        }

        public void createtestChatterGroup(){
            testChatterGroup = new CollaborationGroup(Name = 'Test Chatter Group', CollaborationType = 'Public');
            insert testChatterGroup;
        }

        public void createTestUsersGroup(){
            testUsersGroup = new Group(Name = 'Test Group', Type = 'Regular');
            insert testUsersGroup;
        }

        public void assignUserToTestUsersGroup(){
            GroupMember gm = new GroupMember(UserOrGroupId = testingUser.Id, GroupId = testUsersGroup.Id);
            insert gm;
        }

        public void createChatterGroupAuthorizedUsersRecord(){
            Chatter_Group_Authorized_Users__c c = new Chatter_Group_Authorized_Users__c(Name = 'Test', Chatter_Group_Name__c = 'Test Chatter Group', Group_Name_Of_Authorized_Users__c = 'Test Group');
            insert c;
        }
    }
}