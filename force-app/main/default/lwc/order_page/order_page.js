import { LightningElement, track, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import ZipKartMessageChannel from '@salesforce/messageChannel/ZipKartLMC__c';
import fetchOrderDetails from '@salesforce/apex/ZK_Order_Controller.fetchOrderDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OrderPage extends LightningElement {
    @track orderId;
    @track order;
    @track message = 'Awaiting order confirmation...';

    subscription = null;
    @wire(MessageContext) messageContext;

    // Subscribes to the message channel to get the orderId after 'Place Order' is clicked
    connectedCallback() {
        this.subscribeToMessageChannel();
        this.getOrderDetails();
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

    handleMessage(message) {
        if (message.page === 'order' && message.orderId) {
            this.orderId = message.orderId;
            this.message = 'Fetching order details...';
            this.getOrderDetails();
        }
    }

    // Use a function call instead of @wire since the orderId is received asynchronously
    getOrderDetails() {
        fetchOrderDetails({ orderId: this.orderId })
            .then(result => {
                this.order = result;
                this.message = 'Order details loaded successfully.';
            })
            .catch(error => {
                console.error('Error fetching order details:', JSON.stringify(error));
                this.order = undefined;
                this.message = 'Error loading order details.';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to load order details.',
                        variant: 'error',
                    }),
                );
            });
    }

    get orderItems() {
        // Safely access the OrderItems list
        return this.order?.OrderItems?.records || [];
    }

    get deliveryAddress() {
        if (!this.order) return 'N/A';

        const { BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry } = this.order;
        
        let addressLines = [];
        if (BillingStreet) addressLines.push(BillingStreet);
        let cityStateZip = '';
        if (BillingCity) cityStateZip += BillingCity;
        if (BillingState) cityStateZip += (cityStateZip ? ', ' : '') + BillingState;
        if (BillingPostalCode) cityStateZip += (cityStateZip ? ' ' : '') + BillingPostalCode;
        if (cityStateZip) addressLines.push(cityStateZip);
        if (BillingCountry) addressLines.push(BillingCountry);
        
        return addressLines.join('\n');
    }

    handlePayment() {
        // In a real application, this is where you would call an external payment gateway.
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Payment Successful',
                message: `Payment of $${this.order.TotalAmount} simulated for Order ${this.order.OrderNumber}.`,
                variant: 'success',
            }),
        );
    }
}