import { LightningElement } from 'lwc';
import postAccount from '@salesforce/apex/ZK_Login_Controller.postAccount';

export default class Sign_up_page extends LightningElement {

    user = {
        username: '',
        password: '',
        retypePassword: '',
        firstname: '',
        lastname: '',
        email: '',
        phone: ''
    };

    passwordsMatch = true;

    handleInputChange(event) {
        const name = event.target.name;
        const value = event.target.value;

        this.user[name] = value;

        if (name === 'password' || name === 'retypePassword') {
            this.passwordsMatch =
                this.user.password === this.user.retypePassword;
        }
    }

    handleSubmit() {

        if (!this.passwordsMatch) {
            return;
        }

        postAccount({
            userName: this.user.username,
            password: this.user.password,
            firstname: this.user.firstname,
            lastname: this.user.lastname,
            phone: this.user.phone,
            email: this.user.email
        })
        .then(() => {

            // Redirect back to login after success
            this.dispatchEvent(
                new CustomEvent('navigate', {
                    detail: 'login',
                    bubbles: true,
                    composed: true
                })
            );
        })
        .catch(error => {
            console.error(error);
        });
    }

    fireLoginEvent() {
        this.dispatchEvent(
            new CustomEvent('navigate', {
                detail: 'login',
                bubbles: true,
                composed: true
            })
        );
    }
}