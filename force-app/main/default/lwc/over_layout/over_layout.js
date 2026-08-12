import { LightningElement, api } from 'lwc';

export default class Over_layout extends LightningElement {
    @api isModalOpen = false;
    @api isSignUpModalOpen = false;

    // Method to show the modal when the button is clicked
    handleShowModal() {
        this.isModalOpen = true;
    }

    // Method to close the modal when the close button is clicked
    handleCloseModal() {
        this.isModalOpen = false;
    }

    // Method to show the sign-up modal
    handleShowSignUpModal() {
        this.isSignUpModalOpen = true;
    }

    // Method to close the sign-up modal
    handleCloseSignUpModal() {
        this.isSignUpModalOpen = false;
    }
}