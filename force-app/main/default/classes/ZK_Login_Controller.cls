/**
* @File Name : ZK_Login_Controller.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : September 23, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 23, 2025 |   | Initial Version
**/

public class ZK_Login_Controller 
{
    @AuraEnabled
    public static void LightningStudio(){
        System.debug('Lightning Studio');
    }

    @AuraEnabled
    public static String postAccount(String userName, String password, String firstname, String lastname, String phone, String email, String street, String city, String state, String postal, String country) 
    {
        try {
			// Hash the password before storing it
            String hashedPassword = createPasswordHash(password);
			
            // Create a new Account record
        	Account newAccount = new Account();
            newAccount.Name = userName;
            newAccount.Phone = phone;
            newAccount.BillingStreet = street;
            newAccount.BillingCity = city;
            newAccount.BillingState = state;
            newAccount.BillingPostalCode = postal;
            newAccount.BillingCountry = country;
            newAccount.Password__c = hashedPassword; // Store the hashed password

            
            // Insert the Account
            insert newAccount;

            // Create a new Contact record and link it to the new Account
            Contact newContact = new Contact();
            newContact.FirstName = firstname; // Using username as first name for simplicity
            newContact.LastName = lastname; // Generic last name
            newContact.Phone = phone;
            newContact.Email = email;
            newContact.MailingStreet = street;
            newContact.MailingCity = city;
            newContact.MailingState = state;
            newContact.MailingPostalCode = postal;
            newContact.MailingCountry = country;
            newContact.AccountId = newAccount.Id; // Link Contact to Account
            
            // Insert the Contact
            insert newContact;

            // Return success message
            return 'success';
        } catch (DmlException e) {
            // Handle any DML errors
            System.debug('Error creating Account or Contact: ' + e.getMessage());
            // Return an error message to the client
            return 'error: ' + e.getMessage();
        } catch (Exception e) {
            // Handle other exceptions
            System.debug('An unexpected error occurred: ' + e.getMessage());
            return 'error: ' + e.getMessage();
        }
    }

	 @AuraEnabled
    public static Account loginUser(String userName, String password) {
        if (String.isBlank(userName) || String.isBlank(password)) {
            return null;
        }

        // Hash the provided password to compare with the stored hash
        String hashedPassword = createPasswordHash(password);

        try {
            // Query for an Account with the matching username and hashed password
            Account userAccount = [
                SELECT Id, Name, Phone,  BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
                FROM Account
                WHERE Name = :userName AND Password__c = :hashedPassword
                LIMIT 1
            ];
            
            // Return the account record if found
            return userAccount;

        } catch (Exception e) {
            // Return null if no record is found or an error occurs
            System.debug('Login failed: ' + e.getMessage());
            return null;
        }
    }

    /**
     * @description Creates a secure hash of the provided password using SHA-256.
     * @param password The password string to hash.
     * @return A hexadecimal string representing the hashed password.
     */
    private static String createPasswordHash(String password) {
        Blob passwordBlob = Blob.valueOf(password);
        Blob hashBlob = Crypto.generateDigest('SHA-256', passwordBlob);
        return EncodingUtil.convertToHex(hashBlob);
    }
}