global class notifyClass { 

    public class tifymeException extends Exception {}
    public class tifymeNotification
    {
        String Id;
        String Name;
        Decimal Width;
        String Theme;
        Decimal Height;
        String Message;
    }

    webService static String getUserName()
    {
        return UserInfo.getFirstName();
    }
        
    private static String constructMessage(Notification__c obj)
    {
        String Message = obj.NotificationText__c;
        String Dear = (obj.Salutation__c == null ? '' : obj.Salutation__c);
        String Frm = (obj.From__c == null ? '' : obj.From__c);
        String uName = Dear + ' <b>' + UserInfo.getFirstName() + '</b>, <br /><br />';
        
        return uName + Message + '<br /><br />' + '<p align="right" id="fromField"><b>' + Frm + '</b></p>';
    }

    webservice static String getMessageToShow(Id notifId)
    {
        //Figure out whether to show the message or not !!
        List<Profile> profiles = [select Name from Profile where id = :UserInfo.getProfileId()];
        Id profileId = profiles[0].Id;
        List<Notification__c> MessageList = new List<Notification__c>();

        if(notifId == null)
        {
            MessageList = [select Id, Name, NotificationText__c, From__c, Salutation__c, Theme__c, Width__c, Height__c
                             from Notification__c where Profile__c = :profileId
                             AND Expiration__c >= :datetime.now()
                             AND Id not in (select Notification__c from NotificationMap__c where User__c = :UserInfo.getUserId())
                             AND Active__c = true
                             LIMIT 1];
        }
        else
        {
            MessageList = [select Id, Name, NotificationText__c, From__c, Salutation__c, Theme__c, Width__c, Height__c
                             from Notification__c where Id = :notifId];
        }

        if(MessageList.size() == 0)
        {
            return null;
        }

        String strMsg = constructMessage(MessageList[0]);
        tifymeNotification returnObject = new tifymeNotification();
        returnObject.Id = MessageList[0].Id;
        returnObject.Name = MessageList[0].Name;
        returnObject.Width = MessageList[0].Width__c;
        returnObject.Height = MessageList[0].Height__c;
        returnObject.Theme = MessageList[0].Theme__c;
        returnObject.Message = strMsg;

        return JSON.serialize(returnObject);

    }
    
    webService static void acknowledgeWithId(Id notifId)
    {
        User u = new User(Id = UserInfo.getUserId());
        List<Notification__c> MessageList = [select Id from Notification__c 
                                                    where Id = :notifId LIMIT 1];
        if(MessageList.size() == 0)
        {
            throw new tifymeException('Acknowledge method could not find notification Id : ' + notifId + '. Error inside acknowledgeWithId().');
        }

        Notification__c notif = new Notification__c(Id = MessageList[0].Id);
        NotificationMap__c nm = new NotificationMap__c();
        nm.Notification__c = notif.Id;
        nm.User__c = u.Id;
        insert nm;
    }

/*************************************** HISTORICAL UNUSED METHODS *****************************************/
    /* webService static void acknowledge()
    {
        User u = new User(Id = UserInfo.getUserId());
        List<Profile> profiles = [select Name from Profile where id = :UserInfo.getProfileId()];
        Id profileId = profiles[0].Id;
        List<Notification__c> MessageList = [select Id from Notification__c where Profile__c = :profileId
                             AND Expiration__c >= :datetime.now() 
                             AND Id not in (select Notification__c from NotificationMap__c where User__c = :UserInfo.getUserId())
                             LIMIT 1];
        Notification__c notif = new Notification__c(Id = MessageList[0].Id);
        NotificationMap__c nm = new NotificationMap__c();
        nm.Notification__c = notif.Id;
        nm.User__c = u.Id;
        insert nm;
    }

    
    webService static String getMessageTheme()
    {
        List<Profile> profiles = [select Name from Profile where id = :UserInfo.getProfileId()];
        Id profileId = profiles[0].Id;
        List<Notification__c> MessageList = [select Theme__c from Notification__c 
                             where Profile__c = :profileId
                             AND Active__c = true
                             AND Expiration__c >= :datetime.now() 
                             LIMIT 1];
        if(MessageList.size() == 0)
        {
            return '';
        }
        else
        {
            return MessageList[0].Theme__c;
        }
    }

    webService static String getMessage()
    {
        List<Profile> profiles = [select Name from Profile where id = :UserInfo.getProfileId()];
        Id profileId = profiles[0].Id;
        List<Notification__c> MessageList = [select NotificationText__c, From__c, Salutation__c from Notification__c 
                             where Profile__c = :profileId
                             AND Expiration__c >= :datetime.now() 
                             AND Active__c = true LIMIT 1];
        if(MessageList.size() == 0)
        {
            return '';
        }

        return constructMessage(MessageList[0]);
    } 

    webService static String getMessageThemeWithId(Id notifId)
    {
        List<Notification__c> MessageList = [select Id,Theme__c from Notification__c
                                                where Id = :notifId];
        if(MessageList.size() > 0)
        {
            return MessageList[0].Theme__c;
        }
        return '';
    }
    
    webService static String getMessageWithId(Id notifId)
    {    
        List<Notification__c> tmpList = [select Id, Name, NotificationText__c, From__c, Salutation__c 
                                                from Notification__c
                                                where Id = :notifId];
        if(tmpList.size() == 0)
        {
            throw new tifymeException('No messages could be found for Id : ' + notifId + '. Error inside getMessageWithId().');
        }

        return constructMessage(tmpList[0]);
    }

    */
/*************************************** HISTORICAL UNUSED METHODS *****************************************/    
}