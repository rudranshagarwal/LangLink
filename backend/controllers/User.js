const User = require('../models/User.js')

const getUser = async (data) => {
    try{
        const {phoneNumber} = data;

        // console.log("Finding PhoneNumber : ", phoneNumber);

        return User.find ({
            phoneNumber : phoneNumber
        })
        .then( (user) => {
            if ( user.length === 0 ){
                // socket.emit('noUserFound', { message : 'Not a registered user.'});
                console.log("Not a registered User");
                return ;
            } else {
                // socket.emit('userFound', user);
                console.log("Found the User");
                return user[0];
            }
        })
        .catch( (err) => {
            console.log(`Encountered Error While Retrieving: ${err.message}`);
            // socket.emit('Error', {message : err.message});
            return err; 
        });

    } catch (err){
        console.log(`!! Encountered Error While Finding User: ${err.message}`)
        return err
    }
}

const createUser = async (data) => {
    try{
        const { phoneNumber } = data;

        const newUser = new User ({
            phoneNumber : phoneNumber
        });

        const savedUser = await newUser.save();

        if ( savedUser ){
            // socket.emit('UserCreated', newUser);
            return newUser;
        } else {
            console.log(`!! Encountered Error While Saving`);
            //socket.emit('UserCreationFailed' : { message : 'Could Not Register User.'});
            return;
        }
    }
    catch ( err ){
        console.log(`!! Encountered Error : ${err.message}`);
        return;
    }
}

const setUserPassword = async (data, password) => {
    try{
        const { id } = data;

        // console.log("Data :", data);

        const user = await User.findById( id );
        

        user['password'] = password;
        // No encryption because that is for the nubs.

        const savedUser = await user.save();

        if ( savedUser ){
            //socket.emit('OTPSet', newUser);
            return 0;
        } else {
            console.log(`!! Encountered Error While Setting OTP`);
            // socket.emit('OTPCreationFailed' : { message : 'Could Not Set Password'});
            return 1;
        }
    }
    catch ( err ){
        console.log(`!! Encountered Error : ${err.message}`)
        return 1;
    }
}

const verifyPassword = async ( data ) => {
    try{
        const { id, otp } = data;

        const user = await User.findById( id );

        if ( otp == user.password ){
            // Only comparison needed, frontend can send number or string.
            user.password = 6969;
            newUser = await user.save();
            // socket.emit('OTPVerified' : newUser);
            return 0;
        } else {
            console.log(`OTP Mismatch : OTP -> ${user.password}, Pass -> ${otp}`);
            // socket.emit('OTPMismatch', { message : 'OTP does not match' });
            return 1;
        }
    }
    catch ( err ){
        console.log(`!! Encountered Error : ${err.message}`)
        return 1;
    }
}

module.exports = { getUser, setUserPassword, createUser, verifyPassword }