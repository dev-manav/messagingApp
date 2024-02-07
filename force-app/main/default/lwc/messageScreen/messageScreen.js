import { LightningElement } from 'lwc';
import messageResource from "@salesforce/resourceUrl/messagingResource";
const twilioURL = 'https://api.twilio.com/2010-04-01';
const accountSID = 'ACb72ab7ad5500917d2d058ec77eaad682'

export default class MessageScreen extends LightningElement {
    sendButton = messageResource+'/sendIcon.png';
    profilePic = messageResource+'/profilePic.jpg';
    number = [1,2,3,4,5,6,7,8,9,0]

    sendMessage(){
        console.log('Inside Calling');
        var req = 'https://api.twilio.com/2010-04-01/'+accountSID+'/Messages.json';
        this.getData(req);
        
    }

    async getData(req){
        let data = await fetch(req,{method:'GET'});
        console.log("getting Dta"+JSON.stringify(data));
    }
}