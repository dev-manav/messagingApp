public class MessageCtrl {

    public static String getAuthorizationId(){
        String authorizationId = System.Label.AUTH_ID;

        Http http = new Http();

        //Create Http Request
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Twilio/2010-04-01/Accounts');
        request.setMethod('GET');

        //Send the request and get response
        HttpResponse response = http.send(request);

        System.debug(response.getBody());

        Dom.Document document = new Dom.Document();
        document.load(response.getBody());

        Dom.XmlNode rootElement = document.getRootElement();
        for(Dom.XmlNode childElement: rootElement.getChildElements())
        {
            for(Dom.XmlNode nodeElement: childElement.getChildElements())
            {
                system.debug( nodeElement.getName() + '-' + nodeElement.getText() ); 
            }
        }

        return 'SUCCESS';
    }

    @AuraEnabled()
    public static String sendMessage(String senderNumber, String recieverNumber, String messsageBody){

        String authorizationId = System.Label.AUTH_ID;

        Http http = new Http();

        //Create Http Request
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Twilio/2010-04-01/Accounts/'+authorizationId+'/Messages.json');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        //Create request body
        request.setBody('To=' + EncodingUtil.urlEncode(recieverNumber, 'UTF-8') + '&From='+ EncodingUtil.urlEncode(senderNumber,'UTF-8') + '&Body=' + EncodingUtil.urlEncode(messsageBody,'UTF-8'));

        //Send the request and get response
        HttpResponse response = http.send(request);
        System.debug(response);

        
        return (response.getStatusCode()==Integer.valueOf('201') ? System.Label.MESSAGE_SENT : System.Label.MESSAGE_ERROR);
    }

    @AuraEnabled(cacheable=true)
    public static messageWrapper getMessages(String sender, String reciever){
        List<MessagingApp__c> getMessagesList = new List<MessagingApp__c>();
        String errorMessage = '';
        Boolean isSuccess = false;
        
        SET<String> numbers = new SET<String>{sender, reciever};
        
        try {
            getMessagesList = [SELECT ID, Sender__c, Receiver__c, Message_Body__c FROM MessagingApp__c WHERE Sender__c IN:numbers AND Receiver__c IN:numbers];
            isSuccess = true;
        } catch (QueryException e) {
            errorMessage = e.getMessage();
        }

        return new messageWrapper(getMessagesList, errorMessage, isSuccess);
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