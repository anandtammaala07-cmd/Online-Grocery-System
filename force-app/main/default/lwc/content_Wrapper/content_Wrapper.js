import { LightningElement, api, wire, track } from 'lwc';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import ZipKartMessageChannel from '@salesforce/messageChannel/ZipKartLMC__c';

export default class Content_Wrapper extends LightningElement {
    @wire(MessageContext)
    messageContext;

    subscription = null;
    @track currentPage = 'home';
    @track orderId; // New property to store the orderId
    defaultPage = 'home'

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeFromMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                ZipKartMessageChannel,
                (message) => this.handleMessage(message)
            );
        }
    }

    unsubscribeFromMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    // Handler method that is called when a message is received
    handleMessage(message) {
        console.log('Message received: ', message);
        if (message && message.page) {
            this.currentPage = message.page;

            // Handle order page navigation with a parameter
            if (message.page === 'order' && message.orderId) {
                this.orderId = message.orderId;
            } else {
                this.orderId = null;
            }
        }
    }

    // Getters to conditionally render the correct page
    get isHomePage() {
        return this.currentPage === 'home';
    }

    get isLogInPage() {
        return this.currentPage === 'login';
    }

    get isSearchResultPage() {
        return this.currentPage === 'search';
    }

    get isProductDetailPage() {
        return this.currentPage === 'product';
    }

    get isCartPage() {
        return this.currentPage === 'cart';
    }

    get isOrderPage() { // New getter for the order page
        return this.currentPage === 'order';
    }

    get isTrackPage() {
        return this.currentPage === 'track';
    }
}