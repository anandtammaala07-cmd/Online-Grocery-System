trigger AccountTrigger on Account (after insert, before insert, before update) {
    // This trigger is designed to be "logic-less" and simply calls the handler class.
    // All business logic is encapsulated in the handler for best practices.
    Account a=trigger.new[0];
    a.NumberOfEmployees=1250;
    

    if (Trigger.isAfter && Trigger.isInsert) {
        AccountTriggerHandler.createPrimaryContact(Trigger.new);
    }
    
    map<Id, Account> nMap=new Map<Id, Account>();
    nMap=trigger.newMap;
    List<Contact> cList=[Select LastName, AccountId, MailingCity from Contact where AccountId in:nMap.keySet()];
    
    for(Contact c:cList){
        Account a=nMap.get(c.AccountId);
        c.MailingCity=a.BillingCity;
    }
    
    update cList;
}