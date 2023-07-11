const mongoose = require('mongoose');

const CallSchema = new mongoose.Schema(
    {
        CallerID : {
            type : String,
            required : true,
        },
        CallerNumber : {
            type : String,
            required : true
        },
        CalleeID : {
            type : String,
            required : true,
        },
        CalleeNumber : {
            type : String,
            required : true
        },
        StartTime : {
            type : Number, // ISO formatted date or epoch time.
            default : Date.now()
        },
        CallerChatBot : {
            type : Boolean,
            default : false,
        },
        CalleeChatBot : {
            type : Boolean,
            default : false,
        },
        CallerLang : {
            type : String,
            enum : ["English", "Hindi", "Telugu"],// need to import from somewhere.
            required : true,
            default : "English"
        },
        CalleeLang : {
            type : String,
            enum : ["English", "Hindi", "Telugu"], // need to import from somewhere.
            required : true,
            default : "English"
        },
        Status : {
            type : String,
            enum : ['ongoing', 'missed', 'ended', 'calling', 'declined'],
        },
        Duration : Number,
        TranscriptEntries : { // .id of the TranscriptEntries.
            type : Array,
            default : [],
        }
    }
)

const Call = mongoose.model('Call', CallSchema);

module.exports = Call;