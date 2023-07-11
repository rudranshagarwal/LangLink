const { Configuration, OpenAIApi } = require("openai");

let openAI;

const setup = async () => {
	try {
		const configuration = new Configuration({
			organization: process.env.ORG_API,
			apiKey: process.env.BOT_API,
		});

		openAI = new OpenAIApi(configuration);
	} catch (e) {
		console.log(e.message);
	}
};

const getBotResponse = async (data) => {
	try {
		const completion = await openAI.createChatCompletion({
			model: "gpt-3.5-turbo",
			messages: data,
			temperature: 0.5,
			presence_penalty: 1.0,
			max_tokens: 60,
		});

		console.log(
			`ChatGPT Response : ${completion.data.choices[0].message.content}`
		);

		return completion.data.choices[0].message.content;
	} catch (err) {
		console.log("Can't Send any more requests");
	}
};

module.exports = { setup, getBotResponse };
