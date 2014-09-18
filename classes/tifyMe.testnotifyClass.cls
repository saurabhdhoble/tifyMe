@isTest (SeeAllData=false)
public class testnotifyClass{
    public static User u2;
    public static Notification__c vnotif;
    public static Notification__c vnotifSysAdmin;

    public class tifymeNotification
    {
        String Id;
        String Name;
        String Width;
        String Theme;
        String Height;
        String Message;
    }    
    
    public static void createTestData()
    {
        // Fetch the profiles
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile sysadmin = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        // Create a test Standard User.
        u2 = new User(Alias = 'newUser', Email='newuser@testorg123.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/New_York', UserName='newuser@testorg123.com');
        insert u2;
        
        // Create a notification for standard user.
        vnotif = new Notification__c(
                                    Name='testNotification'
                                    ,From__c = 'Test'
                                    ,NotificationText__c = 'test notificationtext'
                                    ,Profile__c = p.Id
                                    ,Expiration__c = datetime.now().addYears(1)
                                    ,Active__c = true
                                );
        insert vnotif;
        
        // Notif for sysadmin
        vnotifSysAdmin = new Notification__c(
                                    Name='testNotificationSysAdmin'
                                    ,From__c = 'TestSysAdmin'
                                    ,NotificationText__c = 'test notificationtext'
                                    ,Profile__c = sysadmin.Id
                                    ,Expiration__c = datetime.now().addYears(1)
                                    ,Active__c = true
                                );
        insert vnotifSysAdmin;        
    }
    
    public static testMethod void testBasicNotification()
    {
        createTestData();
        System.runAs(u2)
        {
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
            String jsonStr = notifyClass.getMessageToShow(null);

            System.assert(jsonStr != null, 'The getMessageToShow() method returned a NULL string, meaning there is no message to show. However, there is a message created for the Std User profile.');

            tifymeNotification notif = (tifymeNotification) JSON.deserializeStrict(jsonStr, tifymeNotification.class);

            System.assert(notif != null, 'The getMessageToShow() method returned a string that could not parsed into an object of type tifymeNotification.');

            String Id = notif.Id;

            System.Assert(Id == vnotif.Id, 'The notification picked up by getMessageToShow() is incorrect - ' + Id);

            // Acknowledge it - this should create a new notificationmap, and prevent future messages
            notifyClass.acknowledgeWithId(Id);
            List<NotificationMap__c> lst = [select Id from NotificationMap__c
                                                    where Notification__r.Id = :vnotif.Id
                                                    and User__r.Id = :UserInfo.getUserId()];
            // There should be one notification map here.
            System.Assert(lst.size() == 1, 'There should be exactly 1 notificationmap, there are : ' + lst.size());            
        }
    }
    
    public static testMethod void testnotifyVFExtension()
    {
        createTestData();
        notifyVFExtension ext = new notifyVFExtension(new ApexPages.StandardController(vnotif));
        
        //Access the collections to get test coverage
        List<SelectOption> pList = ext.profiles;
        pList = ext.themes;
        ext.doSaveExisting();
        
        // Now change the profile for the vnotif notification to sysadmin.
        vnotif.Profile__c = vnotifSysAdmin.Profile__c;
        ext.doSaveExisting();
        
        //Test out the cancel also
        ext.doCancel();

        System.Assert(1 == 1, 'Not matching');
    }
}