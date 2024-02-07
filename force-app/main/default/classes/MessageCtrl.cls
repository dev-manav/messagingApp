public class MessageCtrl {
    public static HttpResponse sendMessage(){

        String authorizationId = 'ACb72ab7ad5500917d2d058ec77eaad682';
        String authorizationToken= '1e3ec4de1589d8d6d09b213401dc8f0f';
        String endPoint = 'https://api.twilio.com';
        String sender = '+13133273959';
        String reciever = '+918950025769';
        String messageBody = 'Hello Body Sending';

        Http http = new Http();

        //Create Http Request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint+'/2010-04-01/Accounts/'+authorizationId+'/Messages.json');
        request.setMethod('POST');

        //Create Authorization Header
        Blob headerValue = Blob.valueOf(authorizationId+':'+authorizationToken);
        String authorizationHeader = 'BASIC '+EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);

        //Create request body
        request.setBody('To=' + EncodingUtil.urlEncode(reciever, 'UTF-8') + '&From='+ EncodingUtil.urlEncode(sender,'UTF-8') + '&Body=' + EncodingUtil.urlEncode(messageBody,'UTF-8'));

        //Send the request and get response
        HttpResponse response = http.send(request);

        return response;
    }
}

// HttpResponse res = MessageCtrl.sendMessage();