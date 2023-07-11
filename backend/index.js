require("dotenv").config();
const openAI = require("./configs/openAI");
const dbCon = require("./configs/dbCon");

//*Establishing connection with the backend.
console.log("Connecting to MongoDB...");
dbCon.connect();

//*Establishing connection with OpenAI.
console.log("Connecting to OpenAI...");
openAI.setup();

//*Using Express
const express = require("express");
const PORT = process.env.PORT || 4000; //port for https

const server = express() // make the server
	.use((req, res) => res.send("Hi there"))
	.listen(PORT, () => console.log(`Listening on ${PORT}`));

server.on("error", (err) => {
	console.log(`${err.message}`);
});

//*Environment Variables
const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;

//*Twilio Setup
const client = require("twilio")(accountSid, authToken);

let socketIDs = {};
let socketStatus = {};

//*Using Socket.io
const io = require(`socket.io`)(server);

//*Using Middleware
const middleWare = require(`./middleware`);
middleWare.beginCommunication(socketIDs, socketStatus, 	io, client);