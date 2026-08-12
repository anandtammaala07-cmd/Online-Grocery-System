public class AccountTriggerHandler {

    /**
     * @description Creates a new primary contact for every new Account record.
     * @param newAccounts A list of the new Account records that triggered the handler.
     */
    public static void createPrimaryContact(List<Account> newAccounts) {
        // Use a list to store the new Contact records to be inserted.
        List<Contact> contactsToInsert = new List<Contact>();

        // Loop through the new Account records in bulk.
        for (Account acc : newAccounts) {
            // Create a new Contact record for each Account.
            Contact newContact = new Contact();
            newContact.FirstName = 'Primary';
            newContact.LastName = 'Contact';
            newContact.AccountId = acc.Id;
            newContact.Email = 'primary_contact_' + acc.Id + '@example.com';
            
            contactsToInsert.add(newContact);
        }

        // Perform a single DML insert on all the new contacts in one go (bulkified).
        if (!contactsToInsert.isEmpty()) {
            try {
                insert contactsToInsert;
            } catch (DmlException e) {
                System.debug('An error occurred while inserting contacts: ' + e.getMessage());
            }
        }
    }
}