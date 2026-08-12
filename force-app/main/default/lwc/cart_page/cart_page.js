import { LightningElement, track, wire } from 'lwc';
import getCartItems from '@salesforce/apex/ZK_Cart_Controller.getCartItems';
import getOrderDetails from '@salesforce/apex/ZK_Cart_Controller.getOrderDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createOrderFromCart from '@salesforce/apex/ZK_Order_Controller.createOrderFromCart';

// Publish message channel 
import { publish, MessageContext } from 'lightning/messageService';
import ZipKartMessageChannel from '@salesforce/messageChannel/ZipKartLMC__c';

export default class CartPage extends LightningElement {
    @track cartItems = [];
    @track accountId;
    error;

    @wire(MessageContext) messageContext;

    @wire(getCartItems, { accountId: '$accountId' })
    wiredCartItems({ error, data }) {
        console.log('Cart Items: ', data);
        if (data) {
            this.cartItems = data.map(item => ({
                Id: item.Id,
                Name: item.Product_To_Id__r ? item.Product_To_Id__r.Name : 'N/A', 
                ProductCode: item.Product_To_Id__r ? item.Product_To_Id__r.ProductCode : 'N/A',
                Price__c: item.Item_List_Price__c,
                quantity: item.Quantity__c
            }));
            
            const payload = {
                cartItems: `${this.cartItems.length}`
            };
            publish(this.messageContext, ZipKartMessageChannel, payload);

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.cartItems = [];
            console.error('Error fetching cart items:', JSON.stringify(error));
        }
    }

    connectedCallback() {
        this.accountId = sessionStorage.getItem('AccountId');
        console.log('Account ID from sessionStorage:', this.accountId);
    }

    get isCartEmpty() {
        return this.cartItems.length === 0;
    }

    get formattedCartItems() {
        return this.cartItems.map(item => ({
            ...item,
            totalPrice: (item.quantity * item.Price__c || 0).toFixed(2)
        }));
    }

    get cartTotalAmount() {
        let total = this.formattedCartItems.reduce((sum, item) => sum + parseFloat(item.totalPrice), 0);
        return total.toFixed(2);
    }

    /**
     * @description Handles the "Place Order" button click.
     * Calls an Apex method to create an order from the cart.
     */
    // Complete and correct implementation for handlePlaceOrder() in CartPage.js

handlePlaceOrder() {
    // 1. Call the Apex method to create the Order
    createOrderFromCart({ accountId: this.accountId })
        .then(orderId => {
            console.log('Order created with Id:', orderId);
            
            // 2. Show a success toast message
            const evt = new ShowToastEvent({
                title: 'Success!',
                message: 'Order has been placed successfully.',
                variant: 'success',
            });
            this.dispatchEvent(evt);

            // 3. Publish a navigation message to the parent wrapper
            const payload = {
                page: 'order',      // The page to navigate to (e.g., to the OrderSummary component)
                orderId: orderId,   // The ID of the newly created order
                cartItems: '0'      // Update cart count in header component
            };
            publish(this.messageContext, ZipKartMessageChannel, payload);
            
            // 4. Clear the cart view
            this.cartItems = [];
        })
        .catch(error => {
            console.error('Error placing order:', JSON.stringify(error));

            // 5. Show an error toast message
            const evt = new ShowToastEvent({
                title: 'Error!',
                message: 'An error occurred while placing the order. Please try again. Details: ' + error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        });
}
    handlePlaceOrder2() {
        createOrderFromCart({ accountId: this.accountId })
        getOrderDetails({ accountId: this.accountId })
            .then(orderId => {
                console.log('Order created with Id:', orderId);
                
                // Show a success toast message
                const evt = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Order has been placed successfully.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);

                // Publish a navigation message to the parent wrapper
                const payload = {
                    page: 'order', // The page to navigate to
                    orderId: orderId, // The ID of the newly created order
                    cartItems: '0' // Update cart count
                };
                publish(this.messageContext, ZipKartMessageChannel, payload);
                
                // Clear the cart view
                this.cartItems = [];
            })
            .catch(error => {
                console.error('Error placing order:', JSON.stringify(error));

                const evt = new ShowToastEvent({
                    title: 'Error!',
                    message: 'An error occurred while placing the order. Please try again.',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            });
    }
}