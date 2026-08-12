/**
 * @description Controller to handle cart and cart item creation.
 */
public with sharing class ZK_Cart_Controller {
    /**
     * @description Creates a new Cart and related Cart_Item__c records in Salesforce.
     * @param products List of products to add to the cart, with their quantities.
     * @param accountId The Id of the account to associate with the cart.
     * @return Id of the newly created or updated WebCart record.
     */
      @AuraEnabled
    public static Id createCartAndItems(String productsJson, String accountId) {
        
        // Deserialize the JSON string into a list of ProductWrapper objects
        List<ProductWrapper> products = new List<ProductWrapper>();
        try {
            if (String.isNotBlank(productsJson)) {
                products = (List<ProductWrapper>) JSON.deserialize(productsJson, List<ProductWrapper>.class);
            }
        } catch(System.JSONException e) {
            System.debug('JSON Deserialization Error: ' + e.getMessage());
            throw new AuraHandledException('An error occurred with the product data. Please try again.');
        }
        // 1. Check for an existing open cart for the account
        List<Cart1__c> existingCarts = [
            SELECT Id
            FROM Cart1__c
            WHERE AccountId__c = :accountId AND Cart_Status__c = 'Open'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        Cart1__c cart;
        if (existingCarts.isEmpty()) {
            if (products == null || products.isEmpty() || String.isBlank(accountId)) {
                // Added check for null or blank accountId
                return null;
            }
            // 2. If no cart exists, create a new one
            cart = new Cart1__c(
                AccountId__c = accountId,
                Cart_Status__c = 'Open'
            );
            
            try {
                insert cart;
            } catch (DmlException e) {
                System.debug('Error creating cart: ' + e.getMessage());
                throw new AuraHandledException('An error occurred while creating the cart. Please try again.');
            }
        } else {
            // 3. If a cart exists, use it
            cart = existingCarts[0];
            if (products == null || products.isEmpty() || String.isBlank(accountId)) {
                // Added check for null or blank accountId
                // Query for any existing cart items for these products in the current cart
                Map<Id, Cart_item__c> existingCartItemsMap = new Map<Id, Cart_item__c>();
                for(Cart_item__c item : [SELECT Id, Product_To_Id__c, Quantity__c
                              FROM Cart_item__c
                              WHERE CartId__c = :cart.Id
                              WITH SECURITY_ENFORCED]) {
                    existingCartItemsMap.put(item.Product_To_Id__c, item);
                }
                
                List<Cart_Item__c> existingItems = new List<Cart_Item__c>(existingCartItemsMap.values());
                try {
                    delete existingItems;
                    // delete cart;            
                } catch (DmlException e) {
                    System.debug('Error updating cart items: ' + e.getMessage());
                    throw new AuraHandledException('An error occurred while updating the products in the cart. Please try again.');
                }                
            }
            else {
                // filter the items which are not mapped by product so that we can remove those from cart items.                
            }
            System.debug('Products Info for Debug: ' + products);
        }
        
        System.debug('Products Info for Debug: ' + products);
        // Collect the product IDs from the wrapper list to query for existing cart items
        Set<Id> productIdsToUpdate = new Set<Id>();
        for(ProductWrapper product : products) {
            productIdsToUpdate.add(product.productId);
            System.debug('Product Info for Debug: ' + product);
        }
        // Query for any existing cart items for these products in the current cart
        Map<Id, Cart_item__c> existingCartItemsMap = new Map<Id, Cart_item__c>();
        for(Cart_item__c item : [SELECT Id, Product_To_Id__c, Quantity__c
                              FROM Cart_item__c
                              WHERE CartId__c = :cart.Id AND Product_To_Id__c IN :productIdsToUpdate
                              WITH SECURITY_ENFORCED]) {
            existingCartItemsMap.put(item.Product_To_Id__c, item);
        }
        List<Cart_item__c> itemsToInsert = new List<Cart_item__c>();
        Map<Id, Cart_item__c> itemsToUpdateMap = new Map<Id, Cart_item__c>();
        
        // 4. Iterate over the products and create or update cart items
        for (ProductWrapper product : products) {
            if (existingCartItemsMap.containsKey(product.productId)) {
                // Update the quantity of the existing cart item
                Cart_item__c existingItem = existingCartItemsMap.get(product.productId);
                existingItem.Quantity__c = product.quantity;
                itemsToUpdateMap.put(existingItem.Id, existingItem);
                System.debug('Existing cart item updating: ' + existingItem);
            } else {
                // Create a new cart item to insert
                Cart_item__c cartItem = new Cart_item__c(
                    CartId__c = cart.Id,
                    Product_To_Id__c = product.productId,
                    Quantity__c = product.quantity,
                    item_List_Price__c = product.price
                );
                itemsToInsert.add(cartItem);
                System.debug('New cart item inserting: ' + cartItem);
                
            }
        }
        System.debug('Cart item to inserting: ' + itemsToInsert);
        // Perform DML operations in bulk
        if (!itemsToInsert.isEmpty()) {
            try {
                insert itemsToInsert;
            } catch (DmlException e) {
                System.debug('Error creating cart items: ' + e.getMessage());
                // Handle deletion of the parent cart if cart items fail to insert
                delete cart;
                throw new AuraHandledException('An error occurred while adding products to the cart. Please try again.');
            }
        }
        
        // Convert the map values to a list for bulk update
        List<Cart_item__c> itemsToUpdate = itemsToUpdateMap.values();
        if (!itemsToUpdate.isEmpty()) {
            try {
                update itemsToUpdate;
            } catch (DmlException e) {
                System.debug('Error updating cart items: ' + e.getMessage());
                throw new AuraHandledException('An error occurred while updating the products in the cart. Please try again.');
            }
        }
        
        return cart.Id;
    }
     @AuraEnabled(cacheable=true)
    public static List<Cart_item__c> getCartItems2(String accountId) {
        if (String.isBlank(accountId)) {
            return new List<Cart_item__c>();
        }
        // Find the 'Open' cart for the specified account
        List<Cart1__c> existingCarts = [
            SELECT Id
            FROM Cart1__c
            WHERE AccountId__c = :accountId AND Cart_Status__c = 'Open'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        // If no cart is found, return an empty list
        if (existingCarts.isEmpty()) {
            return new List<Cart_item__c>();
        }
        Id cartId = existingCarts[0].Id;
        // Query for all cart items in the found cart, including related product details.
        // The relationship name is assumed to be 'Product__r' based on common conventions.
         List<Cart_item__c> cartItems = [
            SELECT Id, Product_To_Id__c, Quantity__c, item_List_Price__c,
                   Product_To_Id__r.Name, 
                   Product_To_Id__r.ProductCode, 
                   Product_To_Id__r.Family
            FROM Cart_item__c
            WHERE CartId__c = :cartId
            WITH SECURITY_ENFORCED
        ];
        return cartItems;
    }
     @AuraEnabled(cacheable=true)
    public static List<Cart_Item__c> getCartItems(String accountId) {
        if (accountId == null) {
            return new List<Cart_Item__c>();
        }
        
        // This SOQL query now correctly retrieves the related Product2 fields
        return [
            SELECT 
                Id, 
                Product_To_Id__c, 
                Quantity__c, 
                item_List_Price__c, 
                Product_To_Id__r.Name,
                Product_To_Id__r.ProductCode,
                Product_To_Id__r.Family
            FROM 
                Cart_Item__c 
            WHERE 
                CartId__r.AccountId__c = :accountId
            WITH SECURITY_ENFORCED
        ];
    }

    @AuraEnabled(cacheable=true)
public static Order getOrderDetails(Id orderId) {
    if (orderId == null) {
        return null;
    }

    // Query for the specific Order and its related OrderItems
    return [
        SELECT 
            Id, 
            OrderNumber, 
            Status, 
            EffectiveDate, 
            TotalAmount, 
            AccountId, 
            Account.Name,
            (SELECT 
                 Id, 
                 Product2.Name, 
                 Product2.ProductCode, 
                 Quantity, 
                 UnitPrice, 
                 TotalPrice
             FROM OrderItems)
        FROM 
            Order 
        WHERE 
            Id = :orderId
        WITH SECURITY_ENFORCED
        LIMIT 1
    ];
}

    // Wrapper class to pass product data from LWC to Apex
    public class ProductWrapper {
        @AuraEnabled
        public String productId;
        @AuraEnabled
        public Decimal quantity;
        @AuraEnabled
        public Decimal price;
    }
}