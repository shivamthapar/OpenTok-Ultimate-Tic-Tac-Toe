Meteor.Router.add
	'/': 
		to: 'indexTemplate'
		and: ()->
			Session.set('currentGame',null)
	'/game': 
		to: 'gameTemplate'
		and: ()->
			player = getCurrentPlayer()
			if player
				createGame(player.fbId)
				console.log Games
			return

Template.headerTemplate.events {
	'click #logout': ()->
		Meteor.logout()
		url = window.location.replace('../')
}

Template.headerTemplate.myPlayer= ()->
	getCurrentPlayer()

getCurrentPlayer = ->
	if Meteor.user()
		fbId = Meteor.user().profile.fbId
		player = Players.findOne({fbId: fbId},{})
		if player
			return {
				fbId: player.fbId
				name: player.name,
				picture: player.picture,
				score: player.score
			}
	return false
createGame = (playerID)->
	if Session.get('currentGame') != null
		return
	cursor = Games.find {player2: {"$exists": false}} 
	console.log cursor.count()
	console.log "called"
	if cursor.count()>0
		game = cursor.fetch()[0]
		if game.player1!=playerID
			console.log "updated game #{game._id}"
			Games.update game._id,{$set: {player2: playerID}}
			Session.set('currentGame',game._id)
			Session.set('player',2)
	else
		board = [
			[[[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]]],
			[[[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]]],
			[[[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]]]
		]
		player = 1
		lastSubcellClickedCoords = null
		game = {player1: playerID, board : board, turn: player, lastSubcellClickedCoords: lastSubcellClickedCoords}
		Games.insert game
		cursor = Games.find {player1: playerID}
		game = cursor.fetch()[0]
		console.log "created game #{game._id}"
		Session.set('currentGame',game._id)
		Session.set('player',1)
	return
