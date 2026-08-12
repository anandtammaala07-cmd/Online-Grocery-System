public class SOSLClass {

    public static void myMethod()
    {
        List<List<sObject>> l2=[Find 'Ram' Returning Account(Name, NumberOfEmployees), Contact(Name, Phone)];
        
        List<Account> aList=l2[0];
        
        List<Contact> CList=l2[1];
        
        
        for(Account a:aList)
        {
            System.debug(a.Name);
            System.debug(a.NumberOfEmployees);
        }
        
         for(Contact c:CList)
        {
            System.debug(c.Name);
            System.debug(c.Phone);
        }
    }
}