//*DataBase Connection
const UserControls = require("./controllers/User.js");

const sendOTP = async ( client, phoneNumber, userID) => {
	try {
		const random = Math.floor(Math.random() * 9000 + 1000);
		var receiverNumber = phoneNumber;
		const twilioServiceNumber = "+16205165056";
		// console.log("UserID : ", userID);
		const response = await UserControls.setUserPassword(
			{ id: userID },
			random
		);

		if (response == 1) {
			return -1;
		}

		try{
		client.messages
			.create({
				body: `Your LangLink OTP is ${random}`,
				from: twilioServiceNumber,
				to: receiverNumber,
			})
			.then((message) => {
				console.log(`OTP Sent`);
			});
		} catch(err){
			console.log('Invalid PhoneNumber : ${phoneNumber}');
		}
	} catch (err) {
		console.log(`Twilio Error : ${err.message}`);
		return;
	}
}

const verifyOTP = async (userID, otp) => {
	try {
		let message = {};

		const responseObj = await UserControls.verifyPassword({
			id: userID,
			otp: otp,
		});

		if (responseObj === 0) {
			message = {
				verified: "yes",
			};
		} else {
			message = {
				verified: "no",
			};
		}

		return message;
	} catch (err) {
		console.log(`OTP Verification Error : ${err.message}`);
		return {};
	}
}

module.exports = { verifyOTP, sendOTP };