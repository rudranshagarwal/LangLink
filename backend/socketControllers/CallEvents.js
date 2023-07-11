const CallControls = require("../controllers/Call.js");

const CallNumber = async (io, socket, socketStatus, socketIDs, data) => {
	if (socketStatus[socket.id]) {
		const newCall = await CallControls.createCall({
			callerId: data.id,
			calleeNumber: data.callee,
		});

		if (newCall == null) {
			console.log(`Invalid User`);
			return;
		}

		const calleeSocketID = socketIDs[newCall.CalleeID];
		const callerSocketID = socketIDs[newCall.CallerID];
		io.to(callerSocketID).emit(`${newCall.CallerID} Calling`, {
			callID: newCall._id,
		});
		io.to(calleeSocketID).emit(`${newCall.CalleeID} IncomingCall`, {
			callID: newCall._id,
			phoneNumber: data.caller,
		});
	} else {
		return;
	}
};

const CallAccepted = async (io, socket, socketStatus, socketIDs, data) => {
	if (socketStatus[socket.id]) {
		const acceptedCall = await CallControls.acceptCall(data);

		const calleeSocketID = socketIDs[acceptedCall.CalleeID];
		const callerSocketID = socketIDs[acceptedCall.CallerID];
		io.to(callerSocketID).emit(
			`${acceptedCall.CallerID} CallStart`,
			acceptedCall
		);
		io.to(calleeSocketID).emit(
			`${acceptedCall.CalleeID} CallStart`,
			acceptedCall
		);
	} else {
		return;
	}
};

const CallCut = async (io, socket, socketStatus, socketIDs, data) => {
	if (socketStatus[socket.id]) {
		if (data.callID == "") {
			console.log(`CallCut Event Sent Without CallID`);
			return;
		}
		const rejectedCall = await CallControls.endCall(data);

		if (rejectedCall == null) {
			console.log("Failed to End Call");
			return;
		}

		const calleeSocketID = socketIDs[rejectedCall.CalleeID];
		const callerSocketID = socketIDs[rejectedCall.CallerID];

		if (rejectedCall.Status === "missed") {
			io.to(calleeSocketID).emit(
				`${rejectedCall.CalleeID} MissedCall`,
				rejectedCall
			);
			io.to(callerSocketID).emit(
				`${rejectedCall.CallerID} CallEnd`,
				rejectedCall
			);
		} else {
			console.log(`Sending Response For Ending Call`);
			io.to(callerSocketID).emit(
				`${rejectedCall.CallerID} CallEnd`,
				rejectedCall
			);
			io.to(calleeSocketID).emit(
				`${rejectedCall.CalleeID} CallEnd`,
				rejectedCall
			);
		}
	} else {
		return;
	}
};

module.exports = { CallAccepted, CallNumber, CallCut };