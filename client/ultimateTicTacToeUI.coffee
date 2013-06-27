@tictactoeUI = ->
	tictactoe = new TicTacToe()
	board = tictactoe.board
	player = 1
	firstMove = true
	lastSubcellClickedCoords = null
	$subboard = null
	cursor= null
	game_id = Session.get('currentGame')
	me = Session.get('player')
	if game_id != null
			cursor= Games.find {"_id": game_id}
			cursor.observe
				changed: (id, fields)->
					console.log "id"
					console.log id
					console.log "fields"
					console.log fields
					board = fields.board
					player= fields.turn
					$subboard = getRespectiveSubboard(fields.lastSubcellClickedCoords)
					repaintBoard()
	updateDB = ->
		game_id = Session.get('currentGame')
		if game_id != null
			console.log "updated DB"
			Games.update game_id,{$set: {board: board, turn: player, lastSubcellClickedCoords: lastSubcellClickedCoords}}
	pullFromDB = (id,fields)->
		console.log(id)
		console.log(fields)

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
		board[c[0]][c[1]][c[2]][c[3]] = val
	getSubcell = (coords)->
		index = coords[0]*27+coords[1]*9+coords[2]*3+coords[3]
		return $(".subcell:eq(#{index})")
	replaceMarkIcon = ($subcell, type, newState) ->
		mark = ""
		if type == 0
			return
		if type == 1
			mark = "x"
		else
			mark = "o"
		urlString = "img/#{mark}"
		if newState!="normal"
			urlString+= "_#{newState}"
		urlString+=".png"
		$subcell.css "backgroundImage",urlString
		return urlString
	repaintBoard = ->
		setTurnDisplay()
		if $subboard?
			highlightSubboard()
		$(".subcell").each ()->
			c = getCoords $(this)
			mark = getBoardElement c
			xHtmlString = "<span class= 'x'></span>"
			oHtmlString= "<span class= 'o'></span>"
			if mark == 0
				return
			if mark == 1
				$(this).html xHtmlString
			else
				$(this).html oHtmlString
	highlightSubboard = ->
		console.log $subboard
		$(".cell").css "backgroundImage","none"
		$cell = $($subboard.parents('.cell')[0])
		$cell.css "backgroundImage","url(../img/highlight_tile.png)"
	getRespectiveSubboard = (small_cell_coords)->
		c = small_cell_coords
		console.log "c"
		console.log c
		if c==null
			console.log "c is null"
			return
		index = c[2]*3+c[3]
		$subboard = $(".subboard:eq(#{index})")
	parentSubboardWon = (small_cell_coords)->
		c = small_cell_coords
		return tictactoe.subboardWon board[c[0]][c[1]]
	highlightSubboardWon = ($subboard, $lastSubcellClicked, winner, winningMarks, direction) ->
		$cell = $($subboard.parents('.cell')[0])
		if $subboard.has('.line').length>0
			return
		if winner==0 
			return
		color = ""
		if winner == 1
			color = "green"
		else
			color = "red"
		c = getCoords $lastSubcellClicked
		subrow = c[2]
		subcol = c[3]
		row = ""
		col = ""
		switch subrow
			when 0 then row= "top"
			when 1 then row = "middle"
			when 2 then row = "bottom"
		switch subcol
			when 0 then col= "left"
			when 1 then col = "middle"
			when 2 then col = "right"
		classes = "line #{color} "
		switch direction
			when 1 #Horizontal line
				classes+="horiz #{row}"
				$subboard.append("<span class= '#{classes}'></span>")
			when 2 #Vertical line
				classes+="vert #{col}"
				$subboard.append("<span class= '#{classes}'></span>")
			when 3
				$subboard.addClass "leftDiag #{color}"
			when 4
				$subboard.addClass "rightDiag #{color}"
	isSubboardFull = ($subboard)->
		index = $subboard.index '.subboard'
		row = parseInt index/3
		col = index%3
		subboard = board[row][col]
		return tictactoe.subboardFull(subboard)
	setTurnDisplay = ->
		$("#player").removeClass 'o x'
		if player==1
			$("#player").addClass 'x'
		else
			$("#player").addClass 'o'
	repaintBoard()
	$(".subcell").click ->
		console.log "me #{me} player #{player}"
		if me != player
			console.log "i am not the player"
			return
		c = getCoords $(this)
		lastSubcellClickedCoords = c
		if firstMove
			getRespectiveSubboard c
		$parent = $($(this).parents('.subboard')[0])
		if $subboard?
			if isSubboardFull $subboard
				if $parent.is $subboard
					return
			else
				if !$parent.is($subboard) && !firstMove
					return
		setBoardElement c,player
		repaintBoard()
		subboardWon= parentSubboardWon c
		if subboardWon[0]
			highlightSubboardWon $parent, $(this), subboardWon[1], subboardWon[2], subboardWon[3]
		getRespectiveSubboard c
		highlightSubboard()
		won = tictactoe.bigBoardWon board
		if player==1
			player = 2
			console.log "player switched"
		else
			player = 1
			console.log "player switched"
		updateDB()
		firstMove = false
		if won[0]
			alert "won by #{won[1]}"
		return
	return