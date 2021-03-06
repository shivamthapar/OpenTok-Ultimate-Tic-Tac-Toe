Meteor.Router.add
  '/':
    to: 'indexTemplate'
    and: ()->
      Session.set('currentGame',null)
  '/create':
    to: 'createGameTemplate'
    and: ()->
      console.log "router"
      Session.set('querystring',this.querystring.substring(6))
  '/game/:alias':
    to: 'gameTemplate'
    and: (alias)->
      session = Sessions.findOne {alias: alias}
      if session?
        game_id = session.gameId
        ot_session_id = session.otSessionId
        Session.set('currentGame', game_id)
        Session.set('otSessionId', ot_session_id)
        Meteor.call "createToken", ot_session_id, (err,data)->
          console.log "ot_token #{data}"
          Session.set('otToken', data)
          window.initOpenTok(ot_session_id, data)
        game = Games.findOne game_id
        fbId= getCurrentPlayer().fbId 
        console.log game
        if game.player1==fbId
          Session.set('player',1)
          return
        if game.player2==fbId
          Session.set('player',2)
          return
        if !game.player2?
          Session.set('player',2)
          Games.update game._id, {$set: {player2: fbId}}
      else
        fbId = getCurrentPlayer().fbId
        if aliasExists alias
          return
        if !fbId
          return
        session = createSession(alias,fbId)
        console.log session
        console.log "session #{session._id} created"
        url = "/game/#{alias}"
        window.location.replace(url)
      return
  '/game':
    to: 'gameTemplate'
    and: ->
      player = getCurrentPlayer()
      if player
        createTheGame(player.fbId)
        console.log Games
      return
createSession = (alias,playerID)->
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
  index = Games.find({}).count()+1
  game = {index: index, player1: playerID, board : board, bigBoard: big_board, subboardWins: subboard_wins, turn: player, winner: 0,lastSubcellClickedCoords: lastSubcellClickedCoords, status:1}
  Games.insert game
  game = Games.findOne {index: index}
  session = {alias: alias, gameId: game._id}
  Sessions.insert session
  Meteor.call "createOpenTok", alias
  return session

aliasExists = (alias)->
  console.log Sessions.findOne({alias: alias})
  if Sessions.findOne({alias: alias})?
    console.log "alias exists, redirecting"
    return true
  console.log "alias doesn't exist"
  return false

Deps.autorun ()->
  if Meteor.userId()
    $("#facebookModal").modal('hide')

Template.createGameTemplate.events
  'click #createGameButton': ()->
    alias = $("#alias").val()
    url = "/create/#{alias}"
    window.location.replace url

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

Template.createGameTemplate.myPlayer= ()->
  getCurrentPlayer()

Template.createGameTemplate.error = ()->
  if Session.get('querystring')=="gameroomExists"
    return {
      class: "error"
      errorMessage: "The gameroom already exists!"
    }
  console.log "querystring doesnt exist"
  return {}

Template.gameboardTemplate.currentTurn = ()->
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
rowCounter = 1
columnCounter = 1

Template.gameWonModalTemplate.gameWon = ()->
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
 
    return {won: true, winner: player, greeting: greeting}

Template.gameWonModalTemplate.showModal = ()->
  if (Session.get "currentGame")?
    currentGame = Games.findOne( Session.get "currentGame" )
    me = Session.get('player')
    winner = currentGame.winner
    if !winner
      console.log("not won!!!")
      return "false"
    console.log("WON!!!")
    return "true"

Template.waitingForPlayerModalTemplate.showModal = ()->
  if (Session.get "currentGame")?
    currentGame = Games.findOne( Session.get "currentGame" )
    if !("player2" of currentGame) or !currentGame.player2?
      console.log "NO SECOND PLAYER"
      return "true"
    return "false"


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
  console.log("subboardCounter: #{subboardCounter}, index: #{index}")
  if subboardCounter == index
    html = "highlight"
  subboardCounter+=1
  if subboardCounter % 9 == 0
    subboardCounter = 0
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

createTheGame = (playerID)->
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


