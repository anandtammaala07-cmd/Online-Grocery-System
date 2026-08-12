public class SOQLKeywords {

    public static void myMethod()
    {
        List<AggregateResult> argOpp1=[Select StageName From Opportunity Group By StageName];
        System.debug(argOpp1);
        
         List<AggregateResult> argOpp2=[Select Count(Id) From Opportunity Group By StageName];
        System.debug(argOpp2);
        
         List<AggregateResult> argOpp3=[Select StageName,Count(ID) From Opportunity Group By StageName];
        System.debug(argOpp3);
        
        for(AggregateResult op:argOpp3)
        {
            System.debug(op);
        }
        
            List<Opportunity> Slist=[Select Name, StageName From Opportunity Where StageName Like 'Per%']; 
            System.debug(Slist);
    }
}