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
    @track messageList = [];
    @track currentRecordData;
    @track messageLoadedSpinner = false;
    @track sendMessageSpinner = false;

    rowLimit = 5;
    @track offSet = 0;


    @wire(getRecord,{recordId : '$recordId', layoutTypes:'Full'}) 
    record({data, error}){
        if(data){
            this.sendMessageSpinner = true;
            this.currentRecordData = data;
            this.loadMessages();
        }
        else if(error){
            this.showMessage('Error','Error in getting Contact details', 'Error');
        }
    };

    loadMessages(){
        getMessages({sender:this.currentRecordData.fields.Phone.value, receiver:this.currentRecordData.fields.MobilePhone.value, offset: this.offSet, rowLimit: this.rowLimit}).then(data =>{
            let messageList = [];
            data.messageList.forEach(message => {
                if(message.Sender__c==this.currentRecordData.fields.MobilePhone.value){
                    messageList.push({"sender":true,"Message":message.Message_Body__c,"Id":message.Id})
                }
                else{
                    messageList.push({"sender":false,"Message":message.Message_Body__c,"Id":message.Id})
                }
            });

            console.log(messageList);

            messageList = messageList.reverse();

            if(Array.isArray(this.messageList) && this.messageList.length){
                this.messageList = [...messageList , ...this.messageList];
            }
            else{
                this.messageList = messageList;
            }
            this.messageLoadedSpinner = false;
            this.sendMessageSpinner = false;
        })
        .catch(error =>{
            this.showMessage('Error','Error In loading the Messages "'+error+'"','Error');
        })
    }

    loadMore(){
        if(this.messageLoadedSpinner) return;
        this.messageLoadedSpinner = true;
        this.offSet = this.offSet+this.rowLimit;
        this.loadMessages();
    }

    handleScroll(event) {
        const el = event.target;
        if (el.scrollTop == 0) {
            this.loadMore();
        }
    }


    async sendMessage(){
        this.sendMessageSpinner = true;
        let sender = this.currentRecordData.fields.Phone.value;
        let receiver = this.currentRecordData.fields.MobilePhone.value;
        let message = this.template.querySelector('input[data-id="customInput"]').value;
        
        let status= await sendMessage({senderNumber:sender, receiverNumber:receiver, messageBody:message})
        .then(data =>{
            return data;
        })
        .catch(error=>{this.showMessage('Message Not Sent',error,'error')});

        this.sendMessageSpinner = false;

        if(status===undefined){
            this.showMessage('Error','Status '+status,'Error');
        }
        else{
            this.messageList.push({"sender":false,"Message":message,"Id":''});
            this.template.querySelector('input[data-id="customInput"]').value = "";
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