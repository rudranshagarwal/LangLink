const textToText = async (message, sent_language, send_language) => {
	try {
		let translatedText = message;
		const url =
			"https://11fc0468-644c-4cc6-be7d-46b5bffcd914-prod.e1-us-east-azure.choreoapis.dev/aqqz/iiitilmt/1.0.0/onemt";
		const languages = {
			English: "eng",
			Hindi: "hin",
			Telugu: "tel",
		};

		if (sent_language === send_language) {
			return translatedText;
		}

		console.log(
			`Translating From ${sent_language}(${languages[sent_language]}) to ${send_language} (${languages[send_language]})`
		);

		const options = {
			method: "POST",
			headers: {
				accept: "/",
				"Content-Type": "application/json",
				Authorization: `Bearer ${process.env.TRANSLATION_TOKEN}`,
			},
			body: JSON.stringify({
				text: message,
				source_language: languages[sent_language],
				target_language: languages[send_language],
			}),
		};

		await fetch(url, options)
			.then((response) => response.json())
			.then((data) => {
				console.log("TranslatedText", data.data);
				translatedText = data.data;
			})
			.catch((error) => console.error(error));

		return translatedText;
	} catch (err) {
		console.log(`Translation Pipeline Error : ${er.message}`);
	}
}

module.exports = {textToText};