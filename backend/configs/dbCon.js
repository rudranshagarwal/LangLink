const mongoose = require('mongoose')

function connect() {
    const PORT = process.env.PORT || 6969; // *This sets up the port used for connection to MongoDB
    mongoose.set('strictQuery', true); // !This version will be deprecated soon
    mongoose.connect(process.env.MONGODB_URL, {
        useNewURLParser : true,
        useUnifiedTopology : true,
    }).then(() => { console.log(`Connection Established with database on Server Port : ${PORT}`) 
    }).catch(( error ) => console.log(`${error}, could not establish connection.`));
}

module.exports = {
    connect,
};
