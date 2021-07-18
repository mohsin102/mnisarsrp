({
	appendErrorMessage: function(errorMessage, newMessage){
		//console.log('Inside appendErrorMessage function');
		if(errorMessage != ''){
			errorMessage = errorMessage + '\n' + newMessage;
		}
		else{
			errorMessage = newMessage;
		}
		//console.log('errorMessage value is: ' + errorMessage);
		return errorMessage;
	},
	isEmpty: function(obj) {
		return Object.keys(obj).length === 0;
	}
})