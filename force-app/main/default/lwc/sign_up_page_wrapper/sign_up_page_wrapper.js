import { LightningElement } from 'lwc';

export default class Sign_up_page_wrapper extends LightningElement {

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