const TranscriptEntry = require('../models/TranscriptEntry.js');

const Call = require('../models/Call.js');

const createTranscriptEntry = async (data) => {
    try {
        const { callID, text, id, language } = data;
        const senderID = id;
        
        console.log(`Text Sent : ${text}`);

        if (callID === "" ){
            console.log("Data ", data);
            return null;   
        }

        const onGoingCall = await Call.findById(callID);

        if ( senderID === onGoingCall.CallerID ){
            botMode = onGoingCall.CallerChatBot;
            receiverLang = onGoingCall.CalleeLang;

        } else if ( senderID === onGoingCall.CalleeID ){
            botMode = onGoingCall.CalleeChatBot;
            receiverLang = onGoingCall.CallerLang;
        } else {
            console.log("Third Party User");
            return;
        }

        if ( onGoingCall.Status === 'ongoing' ){
            if ( onGoingCall.CallerID === senderID || onGoingCall.CalleeID === senderID ){

                const message = new TranscriptEntry({
                    CallID : callID,
                    SentText : text,
                    SenderID : senderID,
                    SenderLang : language,
                    ReceiverLang : receiverLang,
                    SentByChatBot : botMode,
                })

                const savedMessage = await message.save();

                if ( savedMessage ){
                    onGoingCall.TranscriptEntries.push( savedMessage._id );
                    await onGoingCall.save();

                    console.log('Successfully Created Message.');
                    return { call : onGoingCall, message : savedMessage };
                }else{
                    console.log('Could not create/save the message.');
                    return ;
                }
            }
        } else {
        return null;
        }
    } catch (err){
        console.log(`Error While Creating Message : ${err.message}`);
        return ;
    }
}

const getTranscriptEntry = (data) => {
    try{
        const { transcriptID } = data;

        TranscriptEntry.find(transcriptID)
        .then((message) => {
            console.log('Message Obtained.');
            return message;
        })
        .catch( (err) =>{
            console.log(`Error Encountered : ${err}`);
            return ;
        });
    } catch (err){
    }
}

const setReceiverText = async (data) => {
    try{
        const { messageID,translatedText } = data;

        const transcriptEntry = await TranscriptEntry.findById( messageID );
        
        if ( !translatedText ){
            return transcriptEntry;
        }

        if ( transcriptEntry ){
            if ( transcriptEntry.TranslatedText === '__NO_TEXT_RECEIVED__'){
                transcriptEntry.TranslatedText = translatedText;

                const newTranscriptEntry = await transcriptEntry.save();
                console.log(`Message Translated`);
                return newTranscriptEntry;
            } else {
                console.log('Already modified transcript.');
                return ;
            }
        } else {
            console.log(`No Transcript Found pertaining to current ID`);
            return ;
        }

    }catch(err){
        console.log(`Error While Editing Message : ${err.message}`);
        return ;
    }
}

module.exports = { createTranscriptEntry, setReceiverText: setReceiverText, getTranscriptEntry  };
