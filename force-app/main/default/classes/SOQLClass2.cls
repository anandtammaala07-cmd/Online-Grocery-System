public class SOQLClass2 {

    public static void myMethod(String s)
    {
        List<Contact> conList=[Select firstName, lastName, email From Contact Where firstName ='Arvind'];
        
        List<Contact> conList2=[Select firstName, lastName, email From Contact Where firstName = :s];
        
        System.debug(conList);
        
        System.debug(conList2);
    }
}