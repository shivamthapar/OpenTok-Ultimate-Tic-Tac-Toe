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

Template.gameTemplate.events
  'click #restartGame': ()->
    game_id = Session.get "currentGame"
    if game_id?
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
      Games.update game_id,{$set: {board: board, bigBoard: big_board,subboardWins: subboard_wins, turn: player, winner: winner, lastSubcellClickedCoords: lastSubcellClickedCoords}}
  'click #modalClose': ()->
    $('#myModal').modal('hide')


Template.headerTemplate.myPlayer= ()->
  getCurrentPlayer()

Template.gameTemplate.currentTurn = ()->
  if (Session.get "currentGame")?
    currentGame = Games.findOne( Session.get "currentGame" )
    turn = currentGame.turn
    me = parseInt(Session.get("player"))
    if me==turn
      return "Your"
    return "Opponent's"

Template.gameTemplate.player = () ->
  player = Session.get "player"
  if player?
    if player == 1
      return "x"
    else
      return "o"

subboardCounter = 0
rowCounter = 0
columnCounter = 0

Template.gameTemplate.gameWon = ()->
  if (Session.get "currentGame")?
    currentGame = Games.findOne( Session.get "currentGame" )
    me = Session.get('player')
    winner = currentGame.winner
    if !winner
      console.log "not won"
      return {won: false}
    greeting= ""
    player = ""
    if me==winner
      greeting = "Congrats! You Won!"
    else
      greeting = "You lost :("
    if winner==1
      player= "X"
    else
      player= "O"
    console.log "game won"
    console.log {won: true, winner: player, greeting: greeting}
    $("#myModal").modal('show')
 
    return {won: true, winner: player, greeting: greeting}



Template.gameboardTemplate.boardPosition= ->
  val = ""
  switch rowCounter
    when 0
      val = "top"
    when 1
      val = "middle"
    when 2
      val = "bottom"
  rowCounter += 1
  columnCounter = 0
  console.log "column counter reset to #{columnCounter} "
  return val

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
Template.rowBoardTemplate.boardColumnPosition = ->
  val = ""
  switch columnCounter
    when 0
      val = "left"
    when 1
      val = "middle"
    when 2
      val = "right"
  columnCounter+= 1
  console.log "columnCounter at boardColumnPosition: #{columnCounter}"
  return val

Template.gameboardTemplate.rowBoard= ->
  console.log "rowboard called"
  rowCounter = 0
  subboardCounter = 0
  return @board

rowSubCounter = 0
Template.subboardTemplate.rowSubboard = ->
  rowSubCounter = 0
  return @

Template.subboardTemplate.highlight = ->
  currentGame = Games.findOne( Session.get "currentGame" )
  c = currentGame.lastSubcellClickedCoords
  if c==null
    console.log "c is null"
    return
  index = c[2]*3+c[3]
  html = ""
  if subboardCounter == index
    html = "highlight"
  subboardCounter+=1
  return html

Template.subboardTemplate.subboardRowPosition = ->
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
  if @.valueOf() == 1
    return "x"
  if @.valueOf() == 2
    return "o"

Template.subboardTemplate.rowCounter = ->
  return rowCounter

Template.subboardTemplate.columnCounter = ->
  return columnCounter

Template.subboardTemplate.diagonal = ->
  currentGame = Games.findOne( Session.get "currentGame" )
  if currentGame?
    console.log "subboard: #{subboardCounter}, row/column: #{rowCounter-1},#{columnCounter-1}"
    winner = currentGame.bigBoard[rowCounter-1][columnCounter-1]
    direction = currentGame.subboardWins[rowCounter-1][columnCounter-1]
    color = ""
    if winner==1
      color = "green"
    if winner==2
      color = "red"
    if direction==7
      console.log "leftDiag #{color}"
      return "leftDiag #{color}"
    if direction == 8
      console.log "rightDiag #{color}"
      return "rightDiag #{color}"

Template.subboardTemplate.line = ->
  currentGame = Games.findOne( Session.get "currentGame" )
  if currentGame?
    console.log "subboard: #{subboardCounter}, row/column: #{rowCounter-1},#{columnCounter-1}"
    winner = currentGame.bigBoard[rowCounter-1][columnCounter-1]
    direction = currentGame.subboardWins[rowCounter-1][columnCounter-1]
    color = ""
    if winner==1
      color = "green"
    if winner==2
      color = "red"
    classes = "line #{color} "
    switch direction
      when 0 then classes= ""
      when 1 then classes+= "horiz top"
      when 2 then classes+= "horiz middle"
      when 3 then classes+= "horiz bottom"
      when 4 then classes+= "vert top"
      when 5 then classes+= "vert middle"
      when 6 then classes+= "vert right"
    if direction<7
      return classes

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
