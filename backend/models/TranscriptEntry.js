const mongoose = require('mongoose');

const TranscriptEntrySchema = new mongoose.Schema(
    {
        CallID : {
            type  : String,
            required : true
        },
        TimeStamp : {
            type : Date,
            default : Date.now
        },
        SenderID : {
            type : String,
            required : true,
        },
        Sensitivity : {
            type : Boolean,
            default : false,
        },
        SentByChatBot : {
            type : Boolean,
            default : false,
        },
        SenderLang : {
            type : String,
            enum : ["English", "Hindi", "Telugu"],// need to import from somewhere.
            required : true,
            default : "english"
        },
        ReceiverLang : {
            type : String,
            enum : ["English", "Hindi", "Telugu"], // need to import from somewhere.
            required : true,
            default : "english"
        },
        SentText : {
            type : String,
            default : "__NO_TEXT_SENT__",
            required : true,
        },
        TranslatedText : {
            type : String,
            default : "__NO_TEXT_RECEIVED__",
        }
    }
)

const Transcript = mongoose.model('Transcript', TranscriptEntrySchema);

module.exports = Transcript;
