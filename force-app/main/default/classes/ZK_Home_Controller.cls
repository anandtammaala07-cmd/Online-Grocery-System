/**
* @File Name : ZK_Home_Controller.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : September 18, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 18, 2025 |   | Initial Version
**/

public without sharing class ZK_Home_Controller {
	
    
    /**
     * @description A wrapper class to combine Product2 data with related image data.
     */
    public class ProductWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String ProductCode; 
        @AuraEnabled public String Description;
        @AuraEnabled public String Family; 
        @AuraEnabled public Boolean IsActive; 
        @AuraEnabled public String ProductConsumer; 
        @AuraEnabled public Decimal Price;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public String contentDocumentId;

        public ProductWrapper(Product2 prod, Image img) {
            this.Id = prod.ID;
            this.Name = prod.Name;
            this.ProductCode = prod.ProductCode;
            this.Description = prod.Description;
            this.Family = prod.Family;
            this.IsActive = prod.IsActive;
            this.ProductConsumer = prod.Product_Consumer__c;
            this.Price = prod.Price__c;


            if (img != null) {
                this.imageUrl = img.Url;
                this.contentDocumentId = img.ContentDocumentId;
            } else {
                this.imageUrl = 'https://ddl00000ajrijua4-dev-ed.develop.my.salesforce.com/sfc/p/dL00000aJRIJ/a/dL0000008N7V/2l318EIegz4O0ZERxrs8wsjjtbp9_HFjGykGIYwIXT4';
                this.contentDocumentId = '';
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
	public static List<Account> getHomeScreenData(){
		
		List<Account> accounts = [select id, Name from Account];
		

		return accounts;
	}

	/**
     * @description Retrieves a list of Product2 records based on an optional name filter.
     * This method is cacheable for improved performance in Lightning Web Components.
     * @param searchTerm An optional search term to filter products by name.
     * @return A list of Product2 records.
     */

 @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getProducts3(String searchTerm) {
   
        // Use a bind variable to prevent SOQL injection
        String likeTerm = '%' + searchTerm + '%';

        // Find the standard pricebook ID to ensure we only get standard prices.
        Id standardPricebookId = [
            SELECT Id
            FROM Pricebook2
            WHERE IsStandard = true
            LIMIT 1
        ].Id;

        // Query for products based on the search term, and also
        // query for their related PricebookEntry records.
        List<Product2> products = [
            SELECT Id, Name, ProductCode, Description, Family, IsActive, Product_Consumer__c, Price__c, 
                   (SELECT Id, UnitPrice, Pricebook2Id 
                    FROM PricebookEntries 
                    WHERE Pricebook2Id = :standardPricebookId)
            FROM Product2
            WHERE Name LIKE :likeTerm AND Product_Consumer__c = 'ZipKart'
            LIMIT 100
        ];

        // Loop through the fetched products to update the Price__c field
        Set<Id> productIds = new Set<Id>();
        for (Product2 prod : products) {
            productIds.add(prod.Id);

            // Check if the product has a related PricebookEntry
            if (prod.PricebookEntries != null && !prod.PricebookEntries.isEmpty()) {
                // Update the custom Price__c field with the UnitPrice from the PricebookEntry
                prod.Price__c = prod.PricebookEntries[0].UnitPrice;
            }
        }

        Map<Id, Image> imagesByProductId = new Map<Id, Image>();
        for (Image img : [SELECT Id, Name, Product__C, ContentDocumentId, Url FROM Image WHERE Product__C IN :productIds]) {
            imagesByProductId.put(img.Product__C, img);
        }

        List<ProductWrapper> wrappers = new List<ProductWrapper>();
        for (Product2 prod : products) {
            wrappers.add(new ProductWrapper(prod, imagesByProductId.get(prod.Id)));
        }
        
        // Perform a single DML update on the list of products
        // to save the changes to the database.
        // update products;
        return wrappers;
        // return products;
    }

  @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts2(String searchTerm) {
   
        // Use a bind variable to prevent SOQL injection
        String likeTerm = '%' + searchTerm + '%';

        // Find the standard pricebook ID to ensure we only get standard prices.
        Id standardPricebookId = [
            SELECT Id
            FROM Pricebook2
            WHERE IsStandard = true
            LIMIT 1
        ].Id;

        // Query for products based on the search term, and also
        // query for their related PricebookEntry records.
        List<Product2> products = [
            SELECT Id, Name, ProductCode, Description, Family, IsActive, Product_Consumer__c, Price__c, 
                   (SELECT Id, UnitPrice, Pricebook2Id 
                    FROM PricebookEntries 
                    WHERE Pricebook2Id = :standardPricebookId)
            FROM Product2
            WHERE Name LIKE :likeTerm AND Product_Consumer__c = 'ZipKart'
            LIMIT 100
        ];
         // query for their related PricebookEntry and ProductImage records.
        // List<Product2> products = [
        //     SELECT Id, Name, ProductCode, Description, Family, IsActive, Product_Consumer__c, Price__c, 
        //            (SELECT Id, UnitPrice, Pricebook2Id 
        //             FROM PricebookEntries 
        //             WHERE Pricebook2Id = :standardPricebookId),
        //            (SELECT Id, ContentDocumentId FROM Image)
        //     FROM Product2
        //     WHERE Name LIKE :likeTerm AND Product_Consumer__c = 'ZipKart'
        //     LIMIT 100
        // ];


        // Loop through the fetched products to update the Price__c field
        List<Id> productIds = new List<Id>();
        for (Product2 prod : products) {
            productIds.add(prod.Id);

            // Check if the product has a related PricebookEntry
            if (prod.PricebookEntries != null && !prod.PricebookEntries.isEmpty()) {
                // Update the custom Price__c field with the UnitPrice from the PricebookEntry
                prod.Price__c = prod.PricebookEntries[0].UnitPrice;
            }
        }

        List<Image> images = [SELECT Id, Name, Product__C, ContentDocumentId, Url From Image WHERE Product__C in :productIds];

        for (Product2 prod : products) {
            for(Image img : images)
            {
                if(prod.ID == img.Product__C)
                {
                    // prod.image = img.ContentDocumentId;
                    // prod.url = img.Url;
                }
            }
        }
        
        // Perform a single DML update on the list of products
        // to save the changes to the database.
        // update products;
        
        return products;
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(String searchTerm) {
        
        // Define the list of fields to query
        List<String> fields = new List<String>{
            'Id',
            'Name',
            'ProductCode',
            'Description',
            'Family',
            'IsActive',
            'Product_Consumer__c',
            'Price__c'
        };

        // Construct the SOQL query string dynamically
        String query = 'SELECT ' + String.join(fields, ',') + ' FROM Product2';
        
        // Add a WHERE clause if a search term is provided
        if (String.isNotBlank(searchTerm)) {
            // Use a variable in the WHERE clause to prevent SOQL injection
            String likeTerm = '%' + searchTerm + '%';
            query += ' WHERE Name LIKE :likeTerm';
        }
        else {
            String app = 'ZipKart';
            query += ' WHERE Product_Consumer__c = :app';
        }
        
        // Add an ORDER BY clause for consistent results
        query += ' ORDER BY Name ASC';
        
        // Add a LIMIT clause to prevent exceeding governor limits on large orgs
        query += ' LIMIT 100';

        // Execute the SOQL query
        return Database.query(query);
    }

     @AuraEnabled(cacheable=true)
    public static List<Product2> getProductsWithImages(String searchTerm) {
        String query = 'SELECT Id, Name, Description, ProductCode, Family, Price__c, ' +
                       '(SELECT Id, Title, ContentDocumentId FROM Image) ' +
                       'FROM Product2';

        if (String.isNotBlank(searchTerm)) {
            String likeTerm = '%' + searchTerm + '%';
            query += ' WHERE Name LIKE :likeTerm';
        }
        else {
            String app = 'ZipKart';
            query += ' WHERE Product_Consumer__c = :app';
        }

        query += ' ORDER BY Name ASC LIMIT 100';
        
        return Database.query(query);
    }
}