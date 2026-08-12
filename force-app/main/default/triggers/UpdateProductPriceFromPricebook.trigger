trigger UpdateProductPriceFromPricebook on Pricebook2 (after insert, after update) {
    Set<Id> pricebookIds = new Set<Id>();
    for (Pricebook2 pb : Trigger.new) {
        pricebookIds.add(pb.Id);
    }

    if (!pricebookIds.isEmpty()) {
        // Query related PricebookEntries
        List<PricebookEntry> entries = [
            SELECT Id, UnitPrice, Product2Id
            FROM PricebookEntry
            WHERE Pricebook2Id IN :pricebookIds
                  AND Product2Id != null
        ];

        // Prepare Product2 updates
        Map<Id, Product2> productsToUpdate = new Map<Id, Product2>();
        for (PricebookEntry entry : entries) {
            Product2 prod = new Product2(
                Id = entry.Product2Id,
                Price__c = entry.UnitPrice
            );
            productsToUpdate.put(prod.Id, prod);
        }

        if (!productsToUpdate.isEmpty()) {
            update productsToUpdate.values();
        }
    }
}