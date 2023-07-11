//*DataBase Connection
const UserControls = require("./controllers/User.js");

//*Twilio
const Twilio = require("./twilio.js");

//*UserEvents
const UserEvents = require("./socketControllers/UserEvents.js");

//*CallEvents
const CallEvents = require("./socketControllers/CallEvents.js");

//*TranscriptEvents
const TranscriptEvents = require("./socketControllers/TranscriptEvents.js");

//*FunctionalityEvents
const FunctionalityEvents = require("./socketControllers/FunctionalityEvents.js");

//*AutoPilot
const AutoPilot = require("./autoPilot.js");

const beginCommunication = (socketIDs, socketStatus, io, client) => {	
    try {
		io.on("connect", async (socket) => {
			console.log("Socket-Server Connected. SocketID : ", socket.id);
			socketStatus[socket.id] = true;

			socket.on("disconnect", () => {
				if (socketStatus[socket.id] === true) {
					delete socketStatus[socket.id];
				}
				console.log(`Socket : ${socket.id} Disconnected`);
				return;
			});

			//*Connection Events.
			socket.on(`PhoneNumber`, async (data) => {
				try{
				if (socketStatus[socket.id]) {
					let thisUser = await UserControls.getUser(data);

					if (thisUser === undefined) {
						thisUser = await UserControls.createUser(data);
					}

					// Declaring this connection as active
					socketIDs[thisUser._id] = socket.id;

					//Sending OTP to the user.
					await Twilio.sendOTP(client, data.phoneNumber, thisUser._id);

					data.id = thisUser._id.toString();

					socket.emit(`${data.phoneNumber} UserID`, { id: data.id });

					//*Verification Of OTP
					socket.on(`${data.id} VerifyOTP`, async (data) => {
						if (socketStatus[socket.id]) {
							const response = await Twilio.verifyOTP(data.id, data.otp);
							socket.emit(`${data.id} VerifiedOTP`, response);
						} else {
							return;
						}
					});

					//*Call Controls
					socket.on(`${data.id} CallNumber`, async (data) => {
						await CallEvents.CallNumber(io, socket, socketStatus, socketIDs, data);
					});

					socket.on(`${data.id} CallAccepted`, async (data) => {
						await CallEvents.CallAccepted(io, socket, socketStatus, socketIDs, data);
					});

					socket.on(`${data.id} CallCut`, async (data) => {
						await CallEvents.CallCut(io, socket, socketStatus, socketIDs, data);
					});

					//*User Controls
					socket.on(`${data.id} GetCallHistory`, async (data) => {
						await UserEvents.CallHistory(socket, socketStatus, data);
					})
					
					socket.on(`${data.id} GetLastCall`, async (data) => {
						await UserEvents.LastCall(socket, socketStatus, data);
					});

					socket.on(`${data.id} GetTranscript`, async (data) => {
						await UserEvents.Transcript(socket, socketStatus, data);
					});

					//*Transcript Controls
					socket.on(`${data.id} SendText`, async (data) => {
						let continueCommunication = true;
						while (continueCommunication) {
							await TranscriptEvents.SendText(io, socket, socketStatus, socketIDs, data);
							const newData = await AutoPilot.decide(data);

							if ( newData ) {
								data = newData;
							}else{
								continueCommunication = false;
							}
						} 
					});

					//*Functionality Control
					socket.on(`${data.id} ChangeLanguage`, async (data) => {
						await FunctionalityEvents.ChangeLanguage(socket, socketStatus, data);
					});

					socket.on(`${data.id} ChangeBotMode`, async (data) => {
						await FunctionalityEvents.BotMode(socket, socketStatus, data);
					});
				} else {
					return;
				}}
				catch(err){
                    console.log(err.message);
                }
			});
		});
	} catch (err) {
		console.log(`Encountered the following error : ${err.message}`);
	}

    return io;
};

module.exports = { beginCommunication };