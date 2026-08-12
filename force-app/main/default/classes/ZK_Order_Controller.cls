/**
* @File Name : ZK_Order_Controller.cls
* @Description : Controller to handle Order creation from Cart and fetching Order details.
* @Author :
* @Last Modified By : AI Assistant
* @Last Modified On : September 25, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 25, 2025 |   | Initial Version
* 1.1 | Sep 27, 2025 | AI Assistant | Implemented DML logic for Order creation and fixed SOQL.
**/
public with sharing class ZK_Order_Controller {

    // --- Order Creation (DML) Method ---

    /**
     * @description Creates a new Salesforce Order and OrderItems from the 'Open' Cart1__c 
     * for the account, updates the Cart1__c status to 'Ordered', and deletes the Cart Items.
     * @param accountId The Id of the account.
     * @return The Id of the newly created Order.
     */
    @AuraEnabled
    public static Id createOrderFromCart(String accountId) {
        if (String.isBlank(accountId)) {
            throw new AuraHandledException('Account ID cannot be null for placing an order.');
        }

        // 1. Find the 'Open' cart and its items
        List<Cart1__c> openCarts = [
            SELECT Id, AccountId__c, (SELECT Id, Product_To_Id__c, Quantity__c, item_List_Price__c FROM Cart_Items__r)
            FROM Cart1__c
            WHERE AccountId__c = :accountId AND Cart_Status__c = 'Open'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
System.debug('Cart Fetched');
        if (openCarts.isEmpty() || openCarts[0].Cart_Items__r.isEmpty()) {
            throw new AuraHandledException('No open cart or cart is empty for this account.');
        }
        
        Cart1__c cart = openCarts[0];
        List<Cart_Item__c> cartItems = cart.Cart_Items__r;
System.debug('Cart:'+cart);
        // 2. Find a standard Pricebook Entry for each product in the cart
        Set<Id> productIds = new Set<Id>();
        for (Cart_Item__c item : cartItems) {
            productIds.add(item.Product_To_Id__c);
        }

        Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>([
            SELECT Product2Id, Id, UnitPrice 
            FROM PricebookEntry 
            WHERE Product2Id IN :productIds AND Pricebook2.IsStandard = true
            WITH SECURITY_ENFORCED
        ]);

        // 3. Create a new Order
        Order newOrder = new Order(
            AccountId = cart.AccountId__c,
            Status = 'Draft', // Set initial status
            EffectiveDate = Date.today(),
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id
        );
        insert newOrder; // Insert Order first to get the ID

        // 4. Create Order Items
        List<OrderItem> orderItems = new List<OrderItem>();
        Decimal totalAmount = 0;

        for (Cart_Item__c cartItem : cartItems) {
            PricebookEntry pbe = pbeMap.get(cartItem.Product_To_Id__c);
            
            if (pbe == null) {
                // Handle error: Product not in standard pricebook
                continue; 
            }

            // OrderItem oi = new OrderItem(
            //     OrderId = newOrder.Id,
            //     PricebookEntryId = pbe.Id,
            //     Quantity = cartItem.Quantity__c,
            //     UnitPrice = cartItem.Item_List_Price__c // Use cart item price for total calculation
            //     // TotalAmount = cartItem.Quantity__c * cartItem.Item_List_Price__c
            // );
            // orderItems.add(oi);
            // totalAmount += oi.TotalAmount;
        }

        if (orderItems.isEmpty()) {
            delete newOrder; // Rollback if no items were created
            throw new AuraHandledException('No valid products found to create Order Items.');
        }
        
        insert orderItems;

        // 5. Finalize Order and Cart
        // newOrder.TotalAmount = totalAmount;
        newOrder.Status = 'Placed'; // Update status to reflect a successfully placed order
        update newOrder;

        cart.Cart_Status__c = 'Ordered';
        update cart;

        delete cartItems; // Clean up Cart Items

        return newOrder.Id;
    }


    // --- Order Details Retrieval (Read) Method ---

    /**
     * @description Queries for a specific Order and its details.
     * @param orderId The Id of the Order to retrieve.
     * @return The Order object with Account and OrderItem details.
     */
    @AuraEnabled(cacheable=true)
    public static Order fetchOrderDetails(Id orderId) {
        if (orderId == null) {
            return null;
        }

        // Query the Order, related Account details, and OrderItems
        // We query the primary contact's email as Account.PersonEmail is not always available.
        return [
            SELECT 
                Id, 
                OrderNumber, 
                Status, 
                EffectiveDate, 
                TotalAmount, 
                AccountId, 
                Account.Name,
                Account.Phone, 
                // Account.Primary_Contact__r.Email, // Assuming a lookup field Primary_Contact__c on Account
                BillingStreet, 
                BillingCity, 
                BillingState, 
                BillingPostalCode, 
                BillingCountry,
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
}