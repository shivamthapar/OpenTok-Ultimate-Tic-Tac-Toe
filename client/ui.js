if (Meteor.is_client) {
    Meteor.startup(function () {
        Template.chatTemplate.rendered=function(){
			var $window= $(window);
			var $chat= $("#chat");
			var chatWidth,chatHeight;
			function checkDimensions(){
				chatHeight=$chat.height();
				chatWidth=$chat.width();
				//console.log("chat:"+chatWidth+"x"+chatHeight);
				var chatWindowWidth= 0.8*chatWidth;
				var chatWindowHeight= 3/4*chatWindowWidth;
				var chatContentHeight= chatWindowHeight*2+10;
				if(chatContentHeight>chatHeight){
					//alert("chat height exceeded");
					chatWindowHeight= chatHeight*.4;
					chatWindowWidth=chatWindowHeight*4/3;
					$(".chat-window").width(chatWindowWidth);
					$(".chat-window").height(chatWindowHeight);
				}
				var minWidth= 200;
				var minHeight= 150;
				if(chatWindowWidth>minWidth && chatWindowHeight>minHeight){
					$(".chat-window").width(chatWindowWidth);
					$(".chat-window").height(chatWindowHeight);
				}
			}
			checkDimensions();
			$window.resize(checkDimensions);
		}
    	Template.gameTemplate.rendered=function(){
    		tictactoeUI();
    	}
	});
}