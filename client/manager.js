// Generated by CoffeeScript 1.6.1
(function() {
  var columnCounter, columnSubCounter, createGame, getCurrentPlayer, rowCounter, rowSubCounter;

  Meteor.Router.add({
    '/': {
      to: 'indexTemplate',
      and: function() {
        return Session.set('currentGame', null);
      }
    },
    '/game': {
      to: 'gameTemplate',
      and: function() {
        var player;
        player = getCurrentPlayer();
        if (player) {
          createGame(player.fbId);
          console.log(Games);
        }
      }
    }
  });

  Template.headerTemplate.events({
    'click #logout': function() {
      var url;
      Meteor.logout();
      return url = window.location.replace('../');
    }
  });

  Template.headerTemplate.myPlayer = function() {
    return getCurrentPlayer();
  };

  Template.gameboardTemplate.rendered = function() {
    return console.log("gameboardTemplate is re rendered");
  };

  rowCounter = 0;

  Template.gameboardTemplate.boardPosition = function() {
    rowCounter += 1;
    switch (rowCounter) {
      case 1:
        return "top";
      case 2:
        return "middle";
      case 3:
        rowCounter = 0;
        return "bottom";
    }
  };

  Template.rowBoardTemplate.columnBoard = function() {
    return this;
  };

  columnSubCounter = 0;

  Template.rowBoardTemplate.subboardColumnPosition = function() {
    columnSubCounter += 1;
    switch (columnSubCounter) {
      case 1:
        return "left";
      case 2:
        return "middle";
      case 3:
        columnSubCounter = 0;
        return "right";
    }
  };

  columnCounter = 0;

  Template.rowBoardTemplate.boardColumnPosition = function() {
    columnCounter += 1;
    switch (columnCounter) {
      case 1:
        return "left";
      case 2:
        return "middle";
      case 3:
        columnCounter = 0;
        return "right";
    }
  };

  Template.gameboardTemplate.rowBoard = function() {
    rowCounter = 0;
    return this.board;
  };

  rowSubCounter = 0;

  Template.subboardTemplate.rowSubboard = function() {
    rowSubCounter = 0;
    return this;
  };

  Template.subboardTemplate.subboardRowPosition = function() {
    console.log(this);
    rowSubCounter += 1;
    switch (rowSubCounter) {
      case 1:
        return "top";
      case 2:
        return "middle";
      case 3:
        rowSubCounter = 0;
        return "bottom";
    }
  };

  Template.gameboardTemplate.subBoard = function() {
    return this.board[2][2];
  };

  Template.gameboardTemplate.renderSubcellTop = function() {
    if (this[0][0] === 1) {
      return "x";
    }
    if (this[0][0] === 2) {
      return "o";
    }
  };

  Template.gameboardTemplate.renderBoard2 = function() {
    if (this.board[2][0][2][2] === 1) {
      return "x";
    }
    if (this.board[2][0][2][2] === 2) {
      return "o";
    }
  };

  Template.gameboardTemplate.renderBoard = function() {
    if (this.board[2][0][2][0] === 1) {
      return "x";
    }
    if (this.board[2][0][2][0] === 2) {
      return "o";
    }
  };

  Template.gameboardTemplate.gameboard = function() {
    return Games.findOne(Session.get('currentGame'));
  };

  Template.gameTemplate.rendered = function() {
    return tictactoeUI();
  };

  getCurrentPlayer = function() {
    var fbId, player;
    if (Meteor.user()) {
      fbId = Meteor.user().profile.fbId;
      player = Players.findOne({
        fbId: fbId
      }, {});
      if (player) {
        return {
          fbId: player.fbId,
          name: player.name,
          picture: player.picture,
          score: player.score
        };
      }
    }
    return false;
  };

  createGame = function(playerID) {
    var board, cursor, game, lastSubcellClickedCoords, player;
    cursor = Games.find({
      $or: [
        {
          player2: {
            "$exists": false
          }
        }, {
          $and: [
            {
              status: 1
            }, {
              $or: [
                {
                  player2: playerID
                }, {
                  player1: playerID
                }
              ]
            }
          ]
        }
      ]
    });
    console.log(cursor.count());
    console.log("called");
    if (cursor.count() > 0) {
      game = cursor.fetch()[0];
      if (game.player1 === playerID) {
        Session.set('player', 1);
      }
      if (game.player2 === playerID) {
        Session.set('player', 2);
      }
      if (game.player1 !== playerID && !game.player2) {
        console.log("updated game " + game._id);
        Games.update(game._id, {
          $set: {
            player2: playerID
          }
        });
        Session.set('player', 2);
      }
      Session.set('currentGame', game._id);
      console.log("currentGame: " + game._id);
    } else {
      board = [[[[0, 0, 0], [0, 0, 0], [0, 0, 0]], [[0, 0, 0], [0, 0, 0], [0, 0, 0]], [[0, 0, 0], [0, 0, 0], [0, 0, 0]]], [[[0, 0, 0], [0, 0, 0], [0, 0, 0]], [[0, 0, 0], [0, 0, 0], [0, 0, 0]], [[0, 0, 0], [0, 0, 0], [0, 0, 0]]], [[[0, 0, 0], [0, 0, 0], [0, 0, 0]], [[0, 0, 0], [0, 0, 0], [0, 0, 0]], [[0, 0, 0], [0, 0, 0], [0, 0, 0]]]];
      player = 1;
      lastSubcellClickedCoords = null;
      game = {
        player1: playerID,
        board: board,
        turn: player,
        lastSubcellClickedCoords: lastSubcellClickedCoords,
        status: 1
      };
      Games.insert(game);
      cursor = Games.find({
        player1: playerID
      });
      game = cursor.fetch()[0];
      console.log("created game " + game._id);
      Session.set('currentGame', game._id);
      Session.set('player', 1);
    }
  };

}).call(this);