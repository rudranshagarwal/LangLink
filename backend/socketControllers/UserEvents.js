const CallControls = require('../controllers/Call');

const CallHistory = async (socket, socketStatus, data) => {
	try {
		if (socketStatus[socket.id]) {
			if (data.callID == "") {
				console.log(`CallDetails Event Sent Without CallID`);
				return;
			}

			const callList = await CallControls.getUserCalls(data);

            socket.emit(
				`${data.id} CallHistory`,
				callList
			);
		} else {
			return;
		}
	} catch (err) {
		console.log(err.message);
	}
};

const LastCall = async (socket, socketStatus, data) => {
	try {
        if (socketStatus[socket.id]) {

            const lastCall = await CallControls.getPairWiseCallTranscript(data);
            console.log(`Call Retrieved Successfully ${lastCall}`);

            socket.emit(
                `${data.id} LastCall`,
                lastCall[0]
            );
        } else {
            return;
        }
    } catch (err) {
        console.log(err.message);
    }
};

const Transcript = async (socket, socketStatus, data) => {
    try{
        if (socketStatus[socket.id]) {
            const transcriptList = await CallControls.getCallTranscripts(data);
            
            socket.emit(
                `${data.id} Transcript`,
                transcriptList
            );
        }
    } catch (err) {
        console.log(err.message);
    }
}

module.exports = {CallHistory, Transcript, LastCall};