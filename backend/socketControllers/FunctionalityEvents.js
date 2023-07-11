const CallControls = require("../controllers/Call.js");

const ChangeLanguage = async (socket, socketStatus, data) => {
	if (socketStatus[socket.id]) {
		const newCall = await CallControls.changeLanguage(data);
		console.log(`Changed Language to ${data.language}`);
		// console.log(newCall);
	} else {
		return;
	}
};

const BotMode = async (socket, socketStatus, data) => {
    if (socketStatus[socket.id]) {
        await CallControls.changeBotMode(data);
        console.log(`New Bot Mode: ${data.newBotMode}`);
    } else {
        return;
    }
}

module.exports = {
    ChangeLanguage,
    BotMode
};