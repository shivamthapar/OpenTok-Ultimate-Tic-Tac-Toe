
@tictactoeUI = ->
  tictactoe = new TicTacToe()
  board = tictactoe.board
  big_board = tictactoe.big_board
  subboard_wins = tictactoe.subboard_wins
  player = 1
  firstMove = true
  lastSubcellClickedCoords = null
  $subboard = null
  game_id = Session.get('currentGame')
  me = Session.get('player')

  updateDB = ->
    game_id = Session.get('currentGame')
    if game_id != null
      console.log "updated DB"
      Games.update game_id,{$set: {board: board, bigBoard: big_board, subboardWins: subboard_wins, turn: player, lastSubcellClickedCoords: lastSubcellClickedCoords}}
  
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
    return tictactoe.subboardWon board[c[0]][c[1]]
  addToSubboardWins = (index, winner, winningMarks, direction)->
    console.log big_board
    console.log subboard_wins
    console.log "index #{index} winner #{winner} direction #{direction}"
    big_board[parseInt(index/3)][index%3] = winner
    subboard_wins[parseInt(index/3)][index%3] = direction
    console.log "addToSubboardWins called "
    return
  updateSubboardWins = ->
    if (Session.get "currentGame")?
        currentGame = Games.findOne( Session.get "currentGame" )
        big_board = currentGame.bigBoard
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
    return tictactoe.subboardFull(subboard)

  updateSubboardWins()

  $(".subcell").click ->
    console.log "me #{me} player #{player}"
    if (Session.get "currentGame")?
        currentGame = Games.findOne( Session.get "currentGame" )
        player = currentGame.turn
    if me != player
      console.log "i am not the player"
      return
    c = getCoords $(this)
    lastSubcellClickedCoords = c
    $parent = $($(this).parents('.subboard')[0])
    # if $subboard?
    #   if isSubboardFull $subboard
    #     if $parent.is $subboard
    #       return
    #   else
    #     if !$parent.is($subboard) && !firstMove
    #       return
    setBoardElement c,player
    subboardWon= parentSubboardWon c
    index = $parent.index('.subboard')
    updateSubboardWins()
    if subboardWon[0]
      addToSubboardWins(index, subboardWon[1],subboardWon[2],subboardWon[3])
    won = tictactoe.bigBoardWon board
    if player==1
      player = 2
      console.log "player switched"
    else
      player = 1
      console.log "player switched"
    updateDB()
    if won[0]
      alert "won by #{won[1]}"
  return
