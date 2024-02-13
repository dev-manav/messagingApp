/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class MessageCtrlTest {

    @TestSetup static void makeData(){
        MessagingApp__c message = new MessagingApp__c();
        message.Sender__c = '+1312345678';
        message.Receiver__c = '+918950025769';
        message.Message_Body__c = 'Hello! this is test class';

        insert message;

    }

    

    @isTest static void sendMessage(){

        Test.setMock(HttpCalloutMock.class, new SendMessageMock());

        String sender = '+1312345678';
        String receiver = '+918950025769';
        String messageBody = 'Hello! this is test class';

        Test.startTest();
        MessageCtrl.sendMessage(sender, receiver, messageBody);
        Test.stopTest();
    }

    @isTest static void getMessages() {
        // TO DO: implement unit test
        String sender = '+1312345678';
        String receiver = '+918950025769';
        Integer offset = 5;
        Integer rowLimit = 5;
        
        Test.startTest();
        MessageCtrl.getMessages(sender, receiver, offset, rowLimit);
        Test.stopTest();
    }

    @isTest static void getMessageFromTwilio(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/MessageCtrl';
        req.params.put('From', '+918950025769');
        req.params.put('To', '+1312345678');
        req.params.put('Body', 'Hello! this is test class');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        MessageCtrl.getMessageFromTwilio();
        Test.stopTest();
    }
}