const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema(
    {
        firstName : {
            type : String,
            required : false,
            default : "Chamoli",
            min : 2,
            max : 25,
        },
        lastName : {
            type : String,
            required : false,
            default : "Ashmit",
            max : 25,
        },
        phoneNumber : {
            type : String,
            required : true,
            unique : true,
            min : 7,
            max : 15,
        },
        password : {
            type : String,
            required : false,
            min : 5,
            default : 6969,
            // Need to remove this before deployment.
        }
    }
)

const User = mongoose.model('User', UserSchema);

module.exports = User;
