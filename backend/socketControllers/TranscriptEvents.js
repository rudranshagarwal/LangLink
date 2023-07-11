const TrenControls = require("../controllers/TranscriptEntry.js");

//*TranslationAPI
const TranslateAPI = require("../translate.js");

const SendText = async (io, socket, socketStatus, socketIDs, data) => {
    if (socketStatus[socket.id]) {
        if (data.callID == "") {
            console.log(`Text Sent Without CallID`);
            return;
        }

        const response =
            await TrenControls.createTranscriptEntry(data);

        if (response == null) {
            return;
        }

        //Since ChatGPT cannot send this event,
        // we can set the botMode to false.
        response.message.SentByChatBot = data.botMode;

        if ( data.botMode ){
            console.log(`ChatGPT's Text : ${data.text}`)
            console.log(`TranscriptEntry : ${response.message}`);
        }

        const calleeSocketID =
            socketIDs[response.call.CalleeID];
        const callerSocketID =
            socketIDs[response.call.CallerID];

        if ( response.message.SentText === '__NO_TEXT_SENT__' ){
            return;
        }
        
        if (data.id === response.call.CallerID) {
            io.to(callerSocketID).emit(
                `${response.call.CallerID} TextSent`,
                response.message
            );
        } else {
            io.to(calleeSocketID).emit(
                `${response.call.CalleeID} TextSent`,
                response.message
            );
        }

        let finalMessage = response.message;

        //Now, we need to translate the text.
        const translatedText = await TranslateAPI.textToText(
            response.message.SentText,
            response.message.SenderLang,
            response.message.ReceiverLang
        );

        finalMessage = await TrenControls.setReceiverText({
            messageID: response.message._id,
            translatedText: translatedText,
        });


        if ( finalMessage.SentText == '__NO_TEXT_SENT__' ) {
            return;
        } else if ( finalMessage.TranslatedText == '__NO_TEXT_RECEIVED__'){
            return;
        }

        if (data.id === response.call.CalleeID) {
            io.to(callerSocketID).emit(
                `${response.call.CallerID} IncomingText`,
                finalMessage
            );
        } else {
            io.to(calleeSocketID).emit(
                `${response.call.CalleeID} IncomingText`,
                finalMessage
            );
        }
    } else {
        return;
    }
}


module.exports = {SendText};