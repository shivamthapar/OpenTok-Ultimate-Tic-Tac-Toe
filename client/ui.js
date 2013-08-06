var apiKey,session, publisher;
Template.gameTemplate.rendered = function(){
  console.log("gameTemplate rendered");
  $("#facebookModal").modal('show');
}
Template.gameboardTemplate.rendered = function(){
  tictactoeUI();
}
window.initOpenTok = function(otSessionId, otToken){
    apiKey = 32626492
    session = TB.initSession(otSessionId); // Replace with your own session ID. See https://dashboard.tokbox.com/projects
    session.addEventListener('sessionConnected', sessionConnectedHandler);
    session.addEventListener('sessionDisconnected', sessionDisconnectedHandler);
    session.addEventListener('streamCreated', streamCreatedHandler);
    session.connect(apiKey, otToken); 
}
Template.chatTemplate.rendered=function(){
  console.log("chat tempalte rendered");
  var $window= $(window);
  var $chat= $("#chat");
  var chatWidth,chatHeight;
  TB.addEventListener("exception", exceptionHandler);
  //Replace with your API key and token. See https://dashboard.tokbox.com/projects
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
function sessionConnectedHandler(event) {
 subscribeToStreams(event.streams);
 startPublishing();
}
function sessionDisconnectedHandler(event) {
  // This signals that the user was disconnected from the Session. Any subscribers and publishers
  // will automatically be removed. This default behaviour can be prevented using event.preventDefault()
  publisher = null;
}


function addStream(stream) {
  // Check if this is the stream that I am publishing, and if so do not publish.
  if (stream.connection.connectionId == session.connection.connectionId) {
    return;
  }
  var subscriberDiv = document.createElement('div'); // Create a div for the subscriber to replace
  subscriberDiv.setAttribute('id', stream.streamId); // Give the replacement div the id of the stream as its id.
  subscriberDiv.setAttribute('class','subscriber_div')
  document.getElementById("chat-window-2").appendChild(subscriberDiv);
  var vid_width=$(".chat-window").width();
  var vid_height=$(".chat-window").height();
  var subscriberProps = {width: vid_width, height: vid_height};
  session.subscribe(stream, subscriberDiv.id, subscriberProps);
}
function streamCreatedHandler(event) {
subscribeToStreams(event.streams);
}
function startPublishing(){
var parentDiv = document.getElementById("chat-window-1");
var publisherDiv = document.createElement('div'); // Create a div for the publisher to replace
publisherDiv.setAttribute('id', 'opentok_publisher');
parentDiv.appendChild(publisherDiv);
var vid_width=$(".chat-window").width();
var vid_height=$(".chat-window").height();
var publisherProps = {width: vid_width, height: vid_height};
publisher = TB.initPublisher(apiKey, publisherDiv.id, publisherProps);  // Pass the replacement div id and properties
session.publish(publisher);
}

function subscribeToStreams(streams) {
for (var i = 0; i < streams.length; i++) {
  var stream = streams[i];
  console.log(stream.connection.connectionId+"&"+session.connection.connectionId);
  if (stream.connection.connectionId != session.connection.connectionId) {
    addStream(stream);
  }
}
}

function exceptionHandler(event) {
alert(event.message);
}
