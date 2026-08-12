/**
 * @description Service class to call an external API for real-time tax calculation.
 * This pattern is used for dynamic data that must not be cached,
 * such as current tax rates based on customer location.
 */
public with sharing class TaxAPIService {

    // Wrapper class to structure the tax request payload sent to the external API
    public class TaxRequest {
        @AuraEnabled public Decimal totalAmount;
        @AuraEnabled public String shippingPostalCode;
    }

    // Wrapper class to structure the tax response received from the external API
    public class TaxResponse {
        @AuraEnabled public Decimal taxRate;
        @AuraEnabled public Decimal totalTaxAmount;
        @AuraEnabled public String status;
    }

    /**
     * @description Fetches the current tax rate and calculated tax amount from an external service.
     * @param request The TaxRequest wrapper containing order details and location.
     * @return TaxResponse The calculated tax details.
     */
    @AuraEnabled(cacheable=false)
    public static TaxResponse getTaxFromAPI(TaxRequest request) {
        
        // --- 1. Preparation ---
        // This method must be cacheable=false because tax rates change and are location-dependent.
        // We assume a Named Credential named 'ExternalTaxService' is set up in Salesforce.
        
        HttpRequest req = new HttpRequest();
        
        // Use a Named Credential for secure endpoint management
        req.setEndpoint('callout:ExternalTaxService/api/v1/calculate'); 
        
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        // Serialize the Apex wrapper object into JSON to send in the request body
        String requestBody = JSON.serialize(request);
        req.setBody(requestBody);
        
        // --- 2. Execution ---
        Http http = new Http();
        HttpResponse res;
        
        try {
            // Send the request to the external API
            res = http.send(req);
            
            // --- 3. Processing and Error Handling ---
            if (res.getStatusCode() == 200) {
                // Deserialize the JSON response back into the Apex wrapper object
                TaxResponse response = (TaxResponse) JSON.deserialize(res.getBody(), TaxResponse.class);
                return response;
                
            } else {
                // Handle non-200 status codes (e.g., 400 or 500 errors)
                System.debug('Tax API Callout Error Status: ' + res.getStatusCode() + ', Body: ' + res.getBody());
                throw new AuraHandledException('External tax service returned an error status: ' + res.getStatusCode());
            }
            
        } catch (Exception e) {
            // Handle connection or parsing errors
            System.debug('API Callout Exception: ' + e.getMessage());
            throw new AuraHandledException('Failed to connect to the external tax service.');
        }
    }
}