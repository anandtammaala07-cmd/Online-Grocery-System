import { LightningElement } from 'lwc';

export default class Login_page_wrapper extends LightningElement {

    handleNavigation(event) {
        this.dispatchEvent(
            new CustomEvent('navigate', {
                detail: event.detail,
                bubbles: true,
                composed: true
            })
        );
    }
}