import { LightningElement, track, wire  } from 'lwc';
import getHomeScreenData from "@salesforce/apex/ZK_Home_Controller.getHomeScreenData";
import getProducts from '@salesforce/apex/ZK_Home_Controller.getProducts';

export default class TestLWC extends LightningElement {

    @track accounts;

    products;
    error;

    // Use the @wire decorator to call the Apex method with an empty search term
    @wire(getProducts, { searchTerm: '' })
    wiredProducts({ error, data }) {
        if (data) {
            this.products = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.products = undefined;
            console.error('Error fetching products:', error);
        }
    }


    connectedCallback() {
        //code
       //  this.loadHomePageData();
    }

    loadHomePageData()
    {
        getHomeScreenData()
                .then((data)=>{
                    console.log('Test Data Before Loading');
                    this.accounts = data;
                    console.log('Data: ', JSON.stringify(data));
                })
                .catch((error)=>{
                });
    }

}