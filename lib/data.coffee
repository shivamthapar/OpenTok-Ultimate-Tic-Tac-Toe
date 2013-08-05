@Players = new Meteor.Collection "players"
# fbId | name | picture | score
@Games= new Meteor.Collection "games"
# player1 | player2 | board | turn
@Sessions = new Meteor.Collection "sessions"
# alias	| gameId | otSessionId