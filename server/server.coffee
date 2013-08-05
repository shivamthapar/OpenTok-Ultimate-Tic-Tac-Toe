Fiber = Npm.require('fibers')

Accounts.onCreateUser (options, user)->
  if options.profile
    options.profile.fbId = user.services.facebook.id
    options.profile.picture = "http://graph.facebook.com/" + user.services.facebook.id + "/picture/?type=large"
    options.profile.score = 0
    user.profile = options.profile
    addPlayerToDB user.profile
  return user

Accounts.loginServiceConfiguration.remove {
  service: "facebook"
}
Accounts.loginServiceConfiguration.insert {
  service: "facebook"
  appId: "576348209083716"
  secret: "3ff538796ddf79d584c88ec4484c7f34"
}

Meteor.methods
  addPlayerToDB : (profile)->
    console.log "player added"
    count = Players.find({fbId:profile.id},{}).count()
    if count > 0
      return
    Players.insert {fbId: profile.fbId, name: profile.name, picture: profile.picture, score: profile.score}

  # Meteor.Router.add '/create', 'POST', (id)->
  #   alias = this.request.body.alias
  #   fbId = this.request.body.fbId
  #   if aliasExists alias
  #     console.log "alias #{alias} exists"
  #   else
  #     session = createSession(alias,fbId)
  #   return 

  # createSession = (alias,playerID)->
  #   board = [
  #       [[[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]]],
  #       [[[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]]],
  #       [[[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]]]
  #   ]
  #   big_board = [[0,0,0],[0,0,0],[0,0,0]]
  #   subboard_wins = [[0,0,0],[0,0,0],[0,0,0]]
  #   player = 1
  #   winner = 0
  #   lastSubcellClickedCoords = null
  #   game = {player1: playerID, board : board, bigBoard: big_board, subboardWins: subboard_wins, turn: player, winner: 0,lastSubcellClickedCoords: lastSubcellClickedCoords, status:1}
  #   Games.insert game
  #   session = {alias: alias, gameId: game._id}
  #   Sessions.insert session
  #   return session

  # aliasExists = (alias)->
  #   cursor=Sessions.find {alias: alias}
  #   if cursor.fetch().length>0
  #     return true
  #   return false

  createTheGame : (playerID)->
    cursor = Games.find {$or:[ {player2: {"$exists": false}}, $and: [{status:1}, $or: [{player2: playerID}, {player1: playerID}] ] ]}
    console.log cursor.count()
    console.log "called"
    if cursor.count()>0
      game = cursor.fetch()[0]
      if game.player1 == playerID
        Session.set('player',1)
      if game.player2 == playerID
        Session.set('player',2)
      if game.player1!=playerID and !game.player2
        console.log "updated game #{game._id}"
        Games.update game._id, {$set: {player2: playerID}}
        Session.set('player',2)
      Session.set('currentGame',game._id)
      console.log "currentGame: #{game._id}"
    else
      board = [
        [[[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]]],
        [[[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]]],
        [[[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]]]
      ]
      big_board = [[0,0,0],[0,0,0],[0,0,0]]
      subboard_wins = [[0,0,0],[0,0,0],[0,0,0]]
      player = 1
      winner = 0
      lastSubcellClickedCoords = null
      game = {player1: playerID, board : board, bigBoard: big_board, subboardWins: subboard_wins, turn: player, winner: 0,lastSubcellClickedCoords: lastSubcellClickedCoords, status:1}
      Games.insert game
      cursor = Games.find {player1: playerID}
      game = cursor.fetch()[0]
      console.log "created game #{game._id}"
      Session.set('currentGame',game._id)
      Session.set('player',1)
    return

  createOpenTok : (alias)->
    console.log("called")
    session = Sessions.findOne {alias:alias}

    api_key = "32626492"
    api_secret = "0d7c7a0772e3db3e2ab2d4bab6d5e50d4ac355ef"
    ot = new OpenTok.OpenTokSDK api_key,api_secret
    location = "127.0.0.1"

    ot.create_session location, (result)->
      Fiber(-> 
        ot_session_id = result
        Sessions.update session._id, {$set: {otSessionId: ot_session_id}}
      ).run()