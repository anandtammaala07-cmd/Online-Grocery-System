import { LightningElement, api, wire } from 'lwc';
import { subscribe, unsubscribe, publish, MessageContext } from 'lightning/messageService';

import ZipKartMessageChannel from '@salesforce/messageChannel/ZipKartLMC__c';

export default class Login_button extends LightningElement {
    
    // Public properties to be set from the parent component
    @api iconName;
    @api buttonLabel;

    // Track the current page
    subscription = null;
    user = null;
    buttonLabel = "Login";
    // Use the @wire decorator to get the message context
    @wire(MessageContext)
    messageContext;

     // Lifecycle hook to subscribe to the message channel when the component is inserted into the DOM
    connectedCallback() {
        this.checkLoginStatus();        
        this.subscribeToMessageChannel();
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

 // Method to check for an existing login session
    checkLoginStatus() {
        const storedUsername = sessionStorage.getItem('currentUsername');
        console.log(`Login Btn Welcome back, ${this.user}!`);

        if (storedUsername) {
            this.user = storedUsername;
            console.log(`user exist Welcome back, ${this.user}!`);
            // Optionally navigate to the home page if a session exists
            this.buttonLabel = 'Hello ' + this.user + '!';            
        }
    }
    // Handler method that is called when a message is received
    handleMessage(message) {
        console.log('Message received: ', message);
        if (message && message.user) {
                this.user = message.user;
                this.buttonLabel = 'Hello ' + this.user + '!';         
        }
    }

    // Handle the click event and dispatch a custom event
    handleClick(event) {
        const payload = {
            page: 'login'
        };

        publish(this.messageContext, ZipKartMessageChannel, payload);
        console.log('Published message with its context');
    }
}