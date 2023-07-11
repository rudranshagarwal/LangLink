const openAI = require("./configs/openAI");

const CallControls = require("./controllers/Call.js");

const sendAsChatBot = async (data) => {
	try {
		let chatHistory = [];
		const receiverID = data.id;

		const callTranscripts = await CallControls.getCallTranscripts(data);

		for (let i = 0; i < callTranscripts.length; i++) {
			var messageObject = {};
			messageObject.role =
				callTranscripts[i].SenderID === receiverID 
                    ? "user" 
                    : "system";
			messageObject.content =
				callTranscripts[i].SenderID === receiverID
					? callTranscripts[i].SentText
					: callTranscripts[i].TranslatedText;

			chatHistory.push(messageObject);
		}

		// console.log(chatHistory);

		const botResponse = await openAI.getBotResponse(chatHistory);
		// console.log("ChatGPT Response: " + botResponse);
		data.text = botResponse;
	
		// console.log(`Data : ${data}`)
		
		return data;
	} catch (err) {
		console.log("Turning Off ChatGPT");
        return ;
    }
};

const getReceiverBotMode = async (data) => {
	try {
		const { id } = data;

		const currentCall = await CallControls.getCall(data);

		let receiverBotMode = false;

		if (currentCall && currentCall.Status === 'ongoing' && currentCall.CalleeID === id) {
			data.id = currentCall.CallerID;
			receiverBotMode = currentCall.CallerChatBot;
			data.language = currentCall.CallerLang;
		} else if (currentCall && currentCall.Status === 'ongoing' && currentCall.CallerID === id) {
			data.id = currentCall.CalleeID;
			receiverBotMode = currentCall.CalleeChatBot;
			data.language = currentCall.CalleeLang;
		} else if (currentCall && currentCall.Status !== 'ongoing'){
			return;
		} else{
			console.log("Error fetching CallData");
			return;
		}

		data.BotMode = receiverBotMode;
		return data;
	} catch (err) {
		console.log(err.message);
		data.BotMode = false;
		return data;
	}
};

const decide = async (data) => {
	try {
		let newData = await getReceiverBotMode(data);

		if (newData && newData.BotMode === true) {
			newData = await sendAsChatBot(newData);
			console.log(`ReceiverBot is On`);
			newData.botMode = true;
		} else {
			return;
		}

		delete newData.BotMode;
		
		return newData;
	} catch (err) {
		console.log(err.message);
	}
};

module.exports = { decide };
