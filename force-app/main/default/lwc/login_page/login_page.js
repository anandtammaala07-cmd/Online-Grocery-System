import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import ZipKartMessageChannel from '@salesforce/messageChannel/ZipKartLMC__c';
import login from '@salesforce/apex/ZK_Login_Controller.loginUser';

export default class Login_page extends LightningElement {

    @wire(MessageContext) messageContext;

    username = '';
    password = '';

    handleInputChange(event) {
        const name = event.target.name;
        const value = event.target.value;

        if (name === 'username') {
            this.username = value;
        } else if (name === 'password') {
            this.password = value;
        }
    }

    handleLogin() {
        login({
            userName: this.username,
            password: this.password
        })
        .then(result => {
            if (result) {
                sessionStorage.setItem('currentUsername', this.username);
                sessionStorage.setItem('AccountId', result.Id);
                this.navigateToHomePage('home');
            } else {
                console.log('Invalid credentials');
            }
        })
        .catch(error => {
            console.error(error);
        });
    }

    handleGuestLogin() {
        this.navigateToHomePage('home');
    }

    // 🔥 IMPORTANT: enable bubbling
    fireSignupEvent() {
        this.dispatchEvent(
            new CustomEvent('navigate', {
                detail: 'signup',
                bubbles: true,
                composed: true
            })
        );
    }

    navigateToHomePage(pageName) {
        const payload = {
            page: pageName,
            productId: null
        };

        publish(this.messageContext, ZipKartMessageChannel, payload);
    }
}