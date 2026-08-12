public class ClassForSOQL {
public static void myMethodSoql()
{
    List<Account> accList=[Select Id, Name, Type From Account Where Type='Studio'];
    
    for(Account acc:accList)
    {
        System.debug(acc);
    }
    for(Account acc:accList)
        {
            System.debug(acc.Name);
        }
}
}