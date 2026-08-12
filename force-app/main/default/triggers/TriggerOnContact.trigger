trigger TriggerOnContact on Contact (After insert) {

    Contact c=Trigger.new[0];
    Account a=new Account();
    a.Name=c.lastName+' & Company';
    
    insert a;
}