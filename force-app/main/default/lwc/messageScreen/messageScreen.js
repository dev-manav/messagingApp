import { LightningElement, api, wire, track } from 'lwc';
import messageResource from "@salesforce/resourceUrl/messagingResource";
import sendMessage from '@salesforce/apex/MessageCtrl.sendMessage';
import getMessages from '@salesforce/apex/MessageCtrl.getMessages';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MessageScreen extends LightningElement {
    @api recordId;
    sendButtonPic = messageResource+'/sendIcon.png';
    profilePic = messageResource+'/profilePic.jpg';
    @track messageList = [1,2,3];
    @track currentRecordData;


    @wire(getRecord,{recordId : '$recordId', layoutTypes:'Full'}) 
    record({data, error}){
        if(data){
            this.currentRecordData = data;
            getMessages({sender:data.fields.Phone.value, reciever:data.fields.MobilePhone.value}).then(data =>{
                data.forEach(message => {
                    if(message.Sender__c==this.currentRecordData.fields.Phone.value){
                        this.messageList.push({"sender":"Present","Message":message.Message_Body__c})
                    }
                    else{
                        this.messageList.push({"sender":"","Message":message.Message_Body__c})
                    }
                });
                // console.log(JSON.stringify(data.messageList));
                // this.messageList = data.messageList;
                // console.log(this.messageList);
            })
            .catch(error =>{
                console.log('Errro '+error);
            })
            
        }
        else if(error){
            this.showMessage('Error','Error in getting Contact details', 'Error');
        }
    };


    async sendMessage(){
        let sender = this.currentRecordData.fields.Phone.value;
        let reciever = this.currentRecordData.fields.MobilePhone.value;
        let message = this.template.querySelector('input').value;
        
        let status= await sendMessage({senderNumber:sender, recieverNumber:reciever, messsageBody:message})
        .then(data =>{
            return data;
        })
        .catch(error=>{this.showMessage('Message Not Sent',error,'error')});
        if(status===undefined){
            this.showMessage('Error','Status '+status,'Error');
        }
        else{
            var arr = [];
            arr = this.messageList;
            arr.push([message]);
            this.messageList = arr;
            console.log(status);
            this.showMessage(status,status.includes('SUCCESS')?'Message Sent':'Message Not Sent',status);
        }
    }

    showMessage( titile, message, type ){
        const toastEvt = new ShowToastEvent({
            title: titile,
            message: message,
            variant: type
        });
        this.dispatchEvent(toastEvt);
    };
}