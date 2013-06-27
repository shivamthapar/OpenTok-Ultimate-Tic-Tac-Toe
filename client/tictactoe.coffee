###
board = [
	[[[2,2,1],[1,2,0],[0,1,2]], [[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]]],
	[[[0,0,0],[0,0,0],[0,0,0]], [[2,2,1],[1,2,0],[0,1,2]], [[0,0,0],[0,0,0],[0,0,0]]],
	[[[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]], [[2,2,1],[1,2,0],[0,1,2]]]
]
###
class window.TicTacToe
	constructor : ()->


	board : [
		[[[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]]],
		[[[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]]],
		[[[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,0]]]
	]

	#Big board. Represents which subboards have been won by who
	big_board : [[0,0,0],[0,0,0],[0,0,0]]

	subboardFull : (board)->
		for row in board
			for cell in row
				if cell == 0
					return false
		return true

	subboardWon : (board)->
		bool = false
		winner = 0
		winningMarks = []
		direction = 0
		#1 = horiz (-), 2= vert (|), 3= leftdiag (\) 4= rightdiag (/)
		#check Horizontal
		for row in board
			horiz = (row[0] == row[1] == row[2])
			if horiz && row[0]!=0
				bool = bool||horiz
				winner = row[0]
				winningMarks = [row[0],row[1],row[2]]
				direction = 1
		#check vertical
		for i in [0..2]
			vertical= (board[0][i]==board[1][i]==board[2][i])
			if vertical && board[0][i]!=0
				bool = bool || vertical
				winner = board[0][i]
				winningMarks=[board[0][i],board[1][i],board[2][i]]
				direction = 2
		#check diagonal
		diagonal1 = (board[0][0]==board[1][1]==board[2][2])
		if diagonal1 && board[0][0]!=0
			winner = board[0][0]
			winningMarks = [board[0][0],board[1][1],board[2][2]]
			direction = 3
		diagonal2 = (board[0][2]==board[1][1]==board[2][0])
		if diagonal2 && board[0][2]!=0
			winner = board[0][2]
			winningMarks = [board[0][2],board[1][1],board[2][0]]
			direction = 4
		bool = bool||diagonal1||diagonal2
		if winner == 0
			bool = false
		return [bool,winner,winningMarks, direction]
	testSubboardWin : ->
		#no win
		board = [[0,0,0],[1,0,0],[1,0,0]]
		res = subboardWon(board)
		console.log(res[0]+" "+res[1])
		#horiz win
		board = [[1,1,1],[0,2,0],[2,2,1]]
		res = subboardWon(board)
		console.log(res[0]+" "+res[1])
		#diag win
		board = [[2,2,1],[1,2,0],[0,1,2]]
		res = subboardWon(board)
		console.log(res[0]+" "+res[1])
		#vert win
		board = [[0,1,2],[0,1,1],[2,1,0]]
		res = subboardWon(board)
		console.log(res[0]+" "+res[1])

	bigBoardWon : (board) ->
		i = 0
		for row in board
			j = 0
			for sub in row
				subWon = this.subboardWon(sub)
				if subWon[0]
					this.big_board[i][j]=subWon[1]
				j++
			i++
		won = this.subboardWon(this.big_board)
		if won[0]
			console.log("won by "+ won[1])
		return won

	###
	Check if a subboard has been won by a given side. Return whether or not side has won the board.
	board example:
	[[0,0,0],[0,0,0],[0,0,0]]
	0 == empty
	1 == X
	2 == O
	###
