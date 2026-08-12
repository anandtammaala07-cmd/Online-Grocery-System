public class SOQLChildToParent {

    public static void myMethod()
    {
        List<Contact> clist=[select firstName, lastName, Account.Name, Account.NumberOfEmployees from Contact where firstName like 'R%'];
        System.debug(clist);
    }
}