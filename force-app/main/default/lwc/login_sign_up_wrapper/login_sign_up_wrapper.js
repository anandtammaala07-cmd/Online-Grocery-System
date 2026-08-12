import { LightningElement } from 'lwc';

export default class Login_sign_up_wrapper extends LightningElement {

    currentPage = 'login';

    get isLogin() {
        return this.currentPage === 'login';
    }

    get isSignup() {
        return this.currentPage === 'signup';
    }

    handleNavigation(event) {
        console.log('Switching to:', event.detail);
        this.currentPage = event.detail;
    }
}