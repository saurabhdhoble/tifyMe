public with sharing class notifyVFExtension
{
    private final Notification__c notif;
    public ApexPages.StandardController stdController;
    public notifyVFExtension(ApexPages.StandardController ctrlr)
    {
        this.stdController = ctrlr;
        this.notif = (Notification__c) ctrlr.getRecord();
    }

    public List<SelectOption> profiles
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            List<Profile> profiles = [select Id, Name from Profile LIMIT 100];
            for(Profile p : profiles)
            {
                options.add(new SelectOption(p.Id, p.Name));
            }
            return options;
        }
    }
    
    public String ProfileName
    {
        get
        {
            if(this.notif != null)
            {
                //Need to refetch the notification - for some weird reason, the Profile__c field is not fetched
                //in the notif object (guess it fetches only those fields which are referenced by the VF page.
                List<Notification__c> tempList = [select Id, Profile__c from Notification__c
                                                            where id = :notif.Id];
                if(tempList.size() > 0)
                {
                    List<Profile> profs = [select Id,Name from Profile where Id = :tempList[0].Profile__c LIMIT 1];
                    if(profs.size() > 0)
                    {
                        return profs[0].Name;
                    }
                    else
                    {
                        return '';
                    }
                }
                else
                {
                    return '';
                }
            }
            return '';
        }
    }
  
    
    /***************************** METHODS USED BY notifyCreateVF ************************************/
    public PageReference doCancel()
    {
        return this.stdController.cancel();
    }
    
    public PageReference doSave()
    {
        if(checkDupeNotification())
        {
            insert notif;
            PageReference notifPage = new ApexPages.StandardController(notif).view();
            notifPage.setRedirect(true);
            return notifPage;
        }
        return null;
    }
    public List<SelectOption> themes
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('ui-lightness','Lightness'));
            options.add(new SelectOption('ui-darkness','Darkness'));
            options.add(new SelectOption('smoothness','Smoothness'));
            options.add(new SelectOption('start','Start'));
            options.add(new SelectOption('redmond','Redmond'));
            options.add(new SelectOption('sunny','Sunny'));
            options.add(new SelectOption('overcast','Overcast'));
            options.add(new SelectOption('le-frog','Le Frog'));
            options.add(new SelectOption('flick','Flick'));
            options.add(new SelectOption('pepper-grinder','Pepper Grinder'));
            
            return options;
        }
    }
        
    /***************************** METHODS USED BY notifyCreateVF ************************************/
    
    /***************************** METHODS USED BY notifyEditVF ************************************/
    public PageReference doSaveExisting()
    {
        if(checkDupeNotification())
        {
            update notif;
            PageReference notifPage = new ApexPages.StandardController(notif).view();
            notifPage.setRedirect(true);
            return notifPage;
        }
        return null;
    }
    /***************************** METHODS USED BY notifyEditVF ************************************/
    
    /************************************* GENERIC METHODS ******************************************/
    public boolean checkDupeNotification()
    {
        //The goal here is to check if creating this notification would cause it to conflict with another
        //notification that is already configured.
        // Logic - a. get all notifications configured for dates upto the current
        // b. Loop through and detect if any of them is configured for a conflicting profile.
        List<Notification__c> liveNotifications = [select Id, Name, Profile__c, Expiration__c
                                                           from Notification__c
                                                           where Expiration__c > :DateTime.now()
                                                           and Active__c = true
                                                           and Id <> :notif.Id
                                                          ];
        //Loop and detect
        for(Notification__c obj : liveNotifications)
        {
            if(obj.Profile__c == notif.Profile__c)
            {
                List<Profile> profiles = [select id, Name from Profile where id = :obj.Profile__c];
                if (profiles.size() == 0)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No profiles found for Id : ' + obj.Profile__c));
                    return false;
                }
                
                String msgStr = 'Cannot add notification - there is a conflicting notification for the profile '
                                + profiles[0].Name
                                + '. The notification titled [' + obj.Name + '] is configured to fire for this profile '
                                + 'during the same time window. Disable the [' + obj.Name + '] notification to save this one.';
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, msgStr);
                ApexPages.addMessage(msg);
                
                return false;
            }
        }
        
        // Nothing found, return true.
        return true;
    }
}