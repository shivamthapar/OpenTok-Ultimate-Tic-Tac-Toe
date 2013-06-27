Meteor.Router.add
  '/':
    to: 'indexTemplate'
    and: ()->
      Session.set('currentGame',null)
  '/game':
    to: 'gameTemplate'
    and: ->
      player = getCurrentPlayer()
      if player
        createGame(player.fbId)
        console.log Games
      return

Template.headerTemplate.events
  'click #logout': ()->
    Meteor.logout()
    url = window.location.replace('../')

Template.headerTemplate.myPlayer= ()->
  getCurrentPlayer()


Template.gameboardTemplate.rendered= ->
  console.log "gameboardTemplate is re rendered"

rowCounter = 0
Template.gameboardTemplate.boardPosition= ->
  rowCounter += 1
  switch rowCounter
    when 1
      return "top"
    when 2
      return "middle"
    when 3
      rowCounter = 0
      return "bottom"

Template.subboardTemplate.columnSubboard = ->
  return @

Template.rowBoardTemplate.columnBoard = ->
  return @

columnSubCounter = 0
Template.subboardTemplate.subboardColumnPosition = ->
  columnSubCounter += 1
  switch columnSubCounter
    when 1
      return "top"
    when 2
      return "middle"
    when 3
      columnSubCounter = 0
      return "bottom"
columnCounter = 0
Template.rowBoardTemplate.boardColumnPosition = ->
  columnCounter += 1
  switch columnCounter
    when 1
      return "left"
    when 2
      return "middle"
    when 3
      columnCounter = 0
      return "right"

Template.gameboardTemplate.rowBoard= ->
  rowCounter = 0
  return @board

rowSubCounter = 0
Template.subboardTemplate.rowSubboard = ->
  rowSubCounter = 0
  return @

Template.subboardTemplate.highlight = ->
  currentGame = Games.findOne( Session.get "currentGame" )
  if currentGame.lastSubcellClickedCoords == 7
    console.log "dummy function, placeholders"
  return ""

Template.subboardTemplate.subboardRowPosition = ->
  console.log @
  rowSubCounter += 1
  switch rowSubCounter
    when 1
      return "top"
    when 2
      return "middle"
    when 3
      rowSubCounter = 0
      return "bottom"




Template.gameboardTemplate.subBoard= ->
  return @board[2][2]

Template.subboardTemplate.gamePiece = ->
  console.log "game piece"
  console.log @.valueOf()
  if @.valueOf() == 1
    return "x"
  if @.valueOf() == 2
    return "o"
Template.gameboardTemplate.renderBoard2= ->
  if @board[2][0][2][2] == 1
    return "x"
  if @board[2][0][2][2] == 2
    return "o"
Template.gameboardTemplate.renderBoard= ->
  if @board[2][0][2][0] == 1
    return "x"
  if @board[2][0][2][0] == 2
    return "o"
Template.gameboardTemplate.gameboard= ->
  return Games.findOne Session.get( 'currentGame' )

Template.gameTemplate.rendered= ->
  tictactoeUI()

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
    player = 1
    lastSubcellClickedCoords = null
    game = {player1: playerID, board : board, turn: player, lastSubcellClickedCoords: lastSubcellClickedCoords, status:1}
    Games.insert game
    cursor = Games.find {player1: playerID}
    game = cursor.fetch()[0]
    console.log "created game #{game._id}"
    Session.set('currentGame',game._id)
    Session.set('player',1)
  return
