import { LightningElement, api, wire } from 'lwc';
import { subscribe, unsubscribe, publish, MessageContext } from 'lightning/messageService';
import ZipKartMessageChannel from '@salesforce/messageChannel/ZipKartLMC__c';

export default class Cart_Button extends LightningElement {
    
    // Public properties to be set from the parent component
    @api iconName;
    @api buttonLabel;
    @api badgeText;

    // Use the @wire decorator to get the message context
    @wire(MessageContext)
    messageContext;

     // Lifecycle hook to subscribe to the message channel when the component is inserted into the DOM
    connectedCallback() {
        this.subscribeToMessageChannel();
        this.badgeText = "0"
    }

    // Lifecycle hook to unsubscribe when the component is removed from the DOM to prevent memory leaks
    disconnectedCallback() {
        this.unsubscribeFromMessageChannel();
    }

     // Method to subscribe to the message channel
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                ZipKartMessageChannel,
                (message) => this.handleMessage(message)
            );
        }
    }

    // Method to unsubscribe from the message channel
    unsubscribeFromMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    // Handler method that is called when a message is received
    handleMessage(message) {
        console.log('Message received: ', message);
        if (message && message.cartItems) {
        
            this.badgeText = message.cartItems;
        }
    }

    // Handle the click event and dispatch a custom event
    handleClick(event) {
        const payload = {
            page: 'cart',
            productId: null
        };

        publish(this.messageContext, ZipKartMessageChannel, payload);
        console.log('Published message with its context');
    }
}