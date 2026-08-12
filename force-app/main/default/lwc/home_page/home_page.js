import { LightningElement, track, wire, api } from 'lwc';
import getHomeScreenData from "@salesforce/apex/ZK_Home_Controller.getHomeScreenData";
import getProducts from '@salesforce/apex/ZK_Home_Controller.getProducts3';

import createCartAndItems from '@salesforce/apex/ZK_Cart_Controller.createCartAndItems';
import getCartItems from '@salesforce/apex/ZK_Cart_Controller.getCartItems';


//Publish message channel 
import { publish, MessageContext } from 'lightning/messageService';
import ZipKartMessageChannel from '@salesforce/messageChannel/ZipKartLMC__c';

export default class Home_page extends LightningElement {
 @track accounts;

    products;
    error;
    // Use a tracked property to manage the cart state
    @track cartItems = [];
    @track accountId;
    @wire(MessageContext) messageContext;

    // Use the @wire decorator to call the Apex method with an empty search term
    @wire(getProducts, { searchTerm: '' })
    wiredProducts({ error, data }) {
        if (data) {
            this.products = data.map(product => ({
                ...product,
                isInCart: false,
                quantity: 0
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.products = undefined;
            console.error('Error fetching products:', error);
        }
        console.log('Products: ', this.products);
    }

      // Wire service to call the getCartItems Apex method and fetch existing cart items
    @wire(getCartItems, { accountId: '$accountId' })
    wiredCartItems({ error, data }) {
        console.log('Cart items are fetching from home page', data);
        if (data) {
            this.cartItems = data.map(item => ({
                Id: item.Product_To_Id__c,
                // Name: item.Product_To__r.Name,
                // ProductCode: item.Product_To__r.ProductCode,
                // Family: item.Product_To__r.Family,
                Price__c: item.item_List_Price__c,
                quantity: item.Quantity__c,
                isInCart: true
            }));

            //Publish cart count
            const payload = {
                cartItems: `${this.cartItems.length}`
            };
            publish(this.messageContext, ZipKartMessageChannel, payload);
            console.log('Cart Items fetched from Apex:', JSON.stringify(this.cartItems));
        } else if (error) {
            console.error('Error fetching cart items from Apex:', error);
            this.error = error;
        }
    }


    @api product;

    renderedCallback() {
        // Log the image URL whenever component renders
        console.log('Content Rendered');
        if (this.product) {
            console.log('Product Name:', this.product.Name);
            console.log('Image URL:', this.product.imageUrl 
                ? this.product.imageUrl 
                : '/sfc/servlet.shepherd/document/download/069dL00000I1Bn3QAF'
            );
        }
    }


    connectedCallback() {
        this.accountId = sessionStorage.getItem('AccountId');
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

    // Method to handle the "Add to Cart" button click
    addToCart(event) {
        // Get the product Id from the data attribute on the button
        const productId = event.target.dataset.productId;
        
        // Find the product in the list
        const selectedProduct = this.products.find(
            product => product.Id === productId
        );

        console.log('SelectedProduct: ', selectedProduct);
        if (selectedProduct) {
            // Update the isInCart and quantity properties for the selected product
            this.products = this.products.map(product => {
                if (product.Id === productId) {
                    return { ...product, isInCart: true, quantity: 1 };
                }
                return product;
            });
            // Add the product to the cartItems array
            this.cartItems = [...this.cartItems, { ...selectedProduct, quantity: 1 }];
            console.log('Product added to cart:', selectedProduct.Name);
            console.log('Current Cart:', JSON.stringify(this.cartItems));
            
        }
        
        this.createCart();            

         const payload = {
            cartItems: `${this.cartItems.length}`
        };

        publish(this.messageContext, ZipKartMessageChannel, payload);
    }
    
    // Method to handle increasing the product quantity
    increaseQuantity(event) {
        const productId = event.target.dataset.productId;
        
        // Update quantity in the main product list
        this.products = this.products.map(product => {
            if (product.Id === productId) {
                return { ...product, quantity: product.quantity + 1 };
            }
            return product;
        });
        
        // Update quantity in the cart items list
        this.cartItems = this.cartItems.map(item => {
            if (item.Id === productId) {
                return { ...item, quantity: item.quantity + 1 };
            }
            return item;
        });

        this.createCart();            

        const payload = {
            cartItems: `${this.cartItems.length}`
        };
        publish(this.messageContext, ZipKartMessageChannel, payload);
    }

    // Method to handle decreasing the product quantity
    decreaseQuantity(event) {
        const productId = event.target.dataset.productId;
        
        // Update quantity in the main product list
        this.products = this.products.map(product => {
            if (product.Id === productId && product.quantity > 0) {
                return { ...product, quantity: product.quantity - 1, isInCart: (product.quantity - 1) > 0 };
            }
            return product;
        });
        
        // Update quantity in the cart items list and remove if quantity becomes 0
        this.cartItems = this.cartItems.filter(item => {
            if (item.Id === productId) {
                item.quantity--;
                return item.quantity > 0;
            }
            return true;
        });

        this.createCart();
        
        const payload = {
            cartItems: `${this.cartItems.length}`
        };
        publish(this.messageContext, ZipKartMessageChannel, payload);
    }

     createCart() {
        // Prepare the data to be sent to Apex
        const productsToApex = this.cartItems.map(item => ({
            productId: item.Id,
            quantity: item.quantity,
            price: item.Price
        }));

        // console.log('this.cartItems: ', this.cartItems);
        console.log('Products to apex: ', JSON.stringify(productsToApex));
        // console.log('Current Cart:', JSON.stringify(this.cartItems));

        // Placeholder for a real account Id
        // In a real application, you would get this from context or a user record
        const accountId = sessionStorage.getItem('AccountId');
        console.log('Creating Cart Now');
        console.log('Account ID: ', accountId);
        console.log('products: ', productsToApex);
        // Call the Apex method
        console.log('Products to apex before sending: ', JSON.stringify(productsToApex));
        const productsJson = JSON.stringify(productsToApex);

        createCartAndItems({ productsJson: productsJson, accountId: accountId })
            .then(result => {
                console.log('Cart created successfully. Cart ID:', result);
                // Handle success, e.g., show a toast message or navigate to the cart page
            })
            .catch(error => {
                console.error('Error creating cart:', error);
                // Handle error, e.g., show a toast message
            });
    }
}