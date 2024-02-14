@RestResource(urlMapping='/MessageCtrl/*')  //Use * for flexible structure of the endpoint which contain any kind of structure.
global class MessageCtrl {

    public static String getAuthorizationId() {

        String accountSId = null;
            // Create HTTP instance
        Http http = new Http();
            
            // Create HTTP request
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Twilio/2010-04-01/Accounts');
            request.setMethod('GET');
        
            // Send the request and get the response
            HttpResponse response = http.send(request);
        
            // Check the response status
            if (response.getStatusCode() == 200) {
                // Parse the response body
                // 
                Dom.Document document = new Dom.Document();
                document.load(response.getBody());
                DOM.XMLNode root = document.getRootElement().getChildElement('Accounts', null).getChildElement('Account',null);
                accountSId = root.getChildElement('OwnerAccountSid', null).getText();                
            }
        return accountSId;
    }

    @AuraEnabled()
    public static String sendMessage(String senderNumber, String receiverNumber, String messageBody){

        String authorizationId = getAuthorizationId();

        Http http = new Http();

        //Create Http Request
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Twilio/2010-04-01/Accounts/'+authorizationId+'/Messages.json');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        //Create request body
        request.setBody('To=' + EncodingUtil.urlEncode(receiverNumber, 'UTF-8') + '&From='+ EncodingUtil.urlEncode(senderNumber,'UTF-8') + '&Body=' + EncodingUtil.urlEncode(messageBody,'UTF-8'));

        //Send the request and get response
        HttpResponse response = http.send(request);

        if(response.getStatusCode()==Integer.valueOf('201')){
            MessagingApp__c message = new MessagingApp__c();
            message.Sender__c = senderNumber;
            message.Receiver__c = receiverNumber;
            message.Message_Body__c = messageBody;

            insert message;
        }

        
        return (response.getStatusCode()==Integer.valueOf('201') ? System.Label.MESSAGE_SENT : System.Label.MESSAGE_ERROR);
    }

    @AuraEnabled(cacheable=true)
    public static messageWrapper getMessages(String sender, String receiver, Integer offset, Integer rowLimit){
        List<MessagingApp__c> getMessagesList = new List<MessagingApp__c>();
        String errorMessage = '';
        Boolean isSuccess = false;
        
        SET<String> numbers = new SET<String>{sender, receiver};
        
        try {
            String query = 'SELECT ID, Sender__c, Receiver__c, Message_Body__c FROM MessagingApp__c WHERE Sender__c IN :numbers AND Receiver__c IN :numbers ORDER BY CreatedDate DESC';
            if (offSet != null && rowLimit != null) {
                query +=  ' LIMIT ' + String.valueOf(rowLimit) + ' OFFSET ' + String.valueOf(offSet) ;
            }
            getMessagesList = Database.query(query);
            isSuccess = true;
        } catch (QueryException e) {
            errorMessage = e.getMessage();
        }

        return new messageWrapper(getMessagesList, errorMessage, isSuccess);
    }

    @HttpGet
    global static void getMessageFromTwilio() {

        RestResponse response = RestContext.response;

        try {
            RestRequest req = RestContext.request;
            String fromNumber = req.params.get('From');
            String toNumber = req.params.get('To');
            String messageBody = req.params.get('Body');

            MessagingApp__c message = new MessagingApp__c();
            message.Sender__c = fromNumber;
            message.Receiver__c = toNumber;
            message.Message_Body__c = messageBody;

            insert message;

            // Send HTTP 200 OK response back to Twilio
            response.statusCode = 200;
            response.addHeader('Content-Type', 'text/plain');
            response.responseBody = Blob.valueOf('Thanks, We have received your SMS and SFTwilio Integration Support this!') ;

        } catch(Exception e) {
            // Send HTTP error response back to Twilio
            response.statusCode = 500;
            response.addHeader('Content-Type', 'text/plain');
            response.responseBody = Blob.valueOf('Opps! Something is wrong') ;
        }
    }




    public class messageWrapper{
        @AuraEnabled public List<MessagingApp__c> messageList;
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String errorMessage;
        
        public messageWrapper(List<MessagingApp__c> messageList, String errorMessage, Boolean isSuccess){
            this.messageList = messageList;
            this.errorMessage = errorMessage;
            this.isSuccess = isSuccess;
        }
    }


}

// String res = MessageCtrl.getAuthorizationId();