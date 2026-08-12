public class SOSLClass3 {
public static void myMethod()
{
    List<List<sObject>> searchResults =
    [FIND 'Elite*' RETURNING Account(Id, Name Where Type='Prospect')];

List<Account> accList =
    (List<Account>) searchResults[0];

for(Account acc : accList) {
    System.debug(acc.Name);
}
    String s='Find \'Krishna\' Returning Contact(lastName)';
    List<List<sObject>> slist=Search.query(s);
    
    System.debug(slist);
    
}
}