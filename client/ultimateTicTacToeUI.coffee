
@tictactoeUI = ->
  console.log "tictactoeUI called"
  tictactoe = new TicTacToe()
  board = tictactoe.board
  empty_board = tictactoe.board
  big_board = tictactoe.big_board
  subboard_wins = tictactoe.subboard_wins
  player = 1
  firstMove = false
  lastSubcellClickedCoords = null
  $subboard = null
  game_id = Session.get('currentGame')
  me = Session.get('player')
  status = 1
  winner = 0

  updateDB = ->
    game_id = Session.get('currentGame')
    if game_id != null
      console.log "updated DB"
      Games.update game_id,{$set: {board: board, bigBoard: big_board, subboardWins: subboard_wins, turn: player, winner: winner,lastSubcellClickedCoords: lastSubcellClickedCoords, status: status}}
  getCoords = ($subcell) ->
    index = $subcell.index ".subcell"
    big_row = parseInt index/27
    big_cell = parseInt (index%27)/9
    small_row = parseInt (index/3)%3
    small_cell = index%3
    return [big_row, big_cell,small_row,small_cell]
  getBoardElement = (c)->
    return board[c[0]][c[1]][c[2]][c[3]]
  setBoardElement = (c, val)->
    if (Session.get "currentGame")?
        currentGame = Games.findOne( Session.get "currentGame" )
        board = currentGame.board
      board[c[0]][c[1]][c[2]][c[3]] = val
  getSubcell = (coords)->
    index = coords[0]*27+coords[1]*9+coords[2]*3+coords[3]
    return $(".subcell:eq(#{index})")
  # repaintBoard = ->
  #   setTurnDisplay()
  #   if $subboard?
  #     highlightSubboard()
  #   $(".subcell").each ()->
  #     c = getCoords $(this)
  #     mark = getBoardElement c
  #     xHtmlString = "<span class= 'x'></span>"
  #     oHtmlString= "<span class= 'o'></span>"
  #     if mark == 0
  #       return
  #     if mark == 1
  #       $(this).html xHtmlString
  #     else
  #       $(this).html oHtmlString
  # getRespectiveSubboard = (small_cell_coords)->
  #   c = small_cell_coords
  #   console.log "c"
  #   console.log c
  #   if c==null
  #     console.log "c is null"
  #     return
  #   index = c[2]*3+c[3]
  #   $subboard = $(".subboard:eq(#{index})")
  parentSubboardWon = (small_cell_coords)->
    c = small_cell_coords
    console.log board[c[0]][c[1]]
    return tictactoe.subboardWon board[c[0]][c[1]]
  addToSubboardWins = (index, winner, winningMarks, direction)->
    console.log big_board
    console.log subboard_wins
    console.log "index #{index} winner #{winner} direction #{direction}"
    big_board[parseInt(index/3)][index%3] = winner
    subboard_wins[parseInt(index/3)][index%3] = direction
    console.log "addToSubboardWins called "
    return
  pullFromDB = ->
    if (Session.get "currentGame")?
        currentGame = Games.findOne( Session.get "currentGame" )
        board= currentGame.board
        big_board = currentGame.bigBoard
        firstMove = (JSON.stringify(board) == JSON.stringify(empty_board))
        lastSubcellClickedCoords = currentGame.lastSubcellClickedCoords
        console.log("first move is: #{firstMove}")
        subboard_wins = currentGame.subboardWins
        console.log "update subboardwins called"
        console.log subboard_wins
  highlightSubboardWon = () ->
    i = 0
    for row in big_board
      j = 0
      for col in row
        index = i*3+j
        $currentSubboard = $(".subboard:eq(#{index})")
        console.log "index: #{index}"
        console.log $currentSubboard
        console.log "subboard_wins"
        console.log subboard_wins
        color = ""
        switch col
          when 1 then color= "green"
          when 2 then color= "red"
        classes = "line #{color} "
        direction = subboard_wins[i][j]
        console.log "direction: #{direction}"
        switch direction
          when 0 then classes= ""
          when 1 then classes+= "horiz top"
          when 2 then classes+= "horiz middle"
          when 3 then classes+= "horiz bottom"
          when 4 then classes+= "vert top"
          when 5 then classes+= "vert middle"
          when 6 then classes+= "vert right"
        if direction<6
          console.log "classes: #{classes}"
          $currentSubboard.append("<span class= '#{classes}'></span>")
          console.log "appended"
        else
          if direction==7
            $currentSubboard.addClass "leftDiag #{color}"
          if direction==8
            $currentSubboard.addClass "rightDiag #{color}"
        j+=1
      i+=1

  isSubboardFull = ($subboard)->
    index = $subboard.index '.subboard'
    row = parseInt index/3
    col = index%3
    subboard = board[row][col]
    console.log "subboard is full: #{tictactoe.subboardFull(subboard)}"
    return tictactoe.subboardFull(subboard)

  pullFromDB()

  $(".subcell").click ->

    pullFromDB()
    console.log "me #{me} player #{player}"
    if (Session.get "currentGame")?
        currentGame = Games.findOne( Session.get "currentGame" )
        player = currentGame.turn
    if me != player
      console.log "i am not the player"
      return
    if $(this).children('span.o').length>0||$(this).children('span.x').length>0
      return
    c = getCoords $(this)
    if !firstMove
      reservedSubboard = lastSubcellClickedCoords[2]*3+lastSubcellClickedCoords[3]
      $reservedSubboard = $(".subboard:eq(#{reservedSubboard})")
    lastSubcellClickedCoords = c
    $parent = $($(this).parents('.subboard')[0])
    console.log("first move: #{firstMove}")
    if !firstMove && !isSubboardFull($reservedSubboard) && !$parent.hasClass("highlight")
      console.log("IGNORED")
      return
    # if $subboard?
    #   if isSubboardFull $subboard
    #     if $parent.is $subboard
    #       return
    #   else
    #     if !$parent.is($subboard) && !firstMove
    #       return

    subboardAlreadyWon = parentSubboardWon c
    console.log "subboard already won: #{subboardAlreadyWon}"
    setBoardElement c,player
    if !subboardAlreadyWon[0]
      subboardWon= parentSubboardWon c
      index = $parent.index('.subboard')
      if subboardWon[0]
        addToSubboardWins(index, subboardWon[1],subboardWon[2],subboardWon[3])
    else
      console.log "suboard already won"
    winner = tictactoe.bigBoardWon board
    if player==1
      player = 2
      console.log "player switched"
    else
      player = 1
      console.log "player switched"
    updateDB()
    console.log "winner"
    console.log winner
    if !winner
      return
    status = 0
    firstMove = false
    updateDB()
  return
