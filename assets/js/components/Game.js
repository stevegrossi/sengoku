import React from 'react'
import ReactDOM from 'react-dom'
import { Socket } from 'phoenix'
import Token from '../token'
import Board from './Board'
import Players from './Players'
import MoveForm from './MoveForm'

class Game extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      selectedTileId: null,
      movingTo: null,
      playerId: null
    }
  }

  componentDidMount() {
    const self = this;
    this.props.channel.on('update', (new_state) => self.setState(new_state))
    this.joinAsPlayer()
  }

  canJoinGame() {
    return !Token.get(this.props.id)
  }

  tileClicked(id, e) {
    console.log('tileClicked', id)
    if (this.state.playerId !== this.state.current_player_id) return

    const player_owns_tile =
      this.state.tiles[id].owner == this.state.current_player_id

    if (this.state.selectedTileId) {
      // Moving or attacking
      if (player_owns_tile && this.state.selectedTileId !== id) {
        // Moving
        this.setState({ movingTo: id })
        e.stopPropagation()
      } else if (this.state.selectedTileId !== id) {
        // Attacking
        this.action('attack', { from_id: this.state.selectedTileId, to_id: id })
        e.stopPropagation()
      }
    } else {
      if (player_owns_tile) {
        if (this.state.current_player_id && this.state.players[this.state.current_player_id].unplaced_units > 0) {
          // Placing units
          this.action('place_unit', { tile_id: id })
          e.stopPropagation()
        } else {
          // Selecting a tile to move to/attack
          console.log('selecting tile', id)
          this.setState({ selectedTileId: id })
          e.stopPropagation()
        }
      }
    }
  }

  cancelSelection() {
    this.setState({
      selectedTileId: null,
      movingTo: null
    })
  }

  action(type, payload) {
    payload = payload || {}
    payload.type = type
    console.log('action', payload)
    this.props.channel.push('action', payload)
  }

  endTurn() {
    this.cancelSelection()
    this.action('end_turn')
  }

  startGame() {
    this.action('start_game')
  }

  joinAsPlayer() {
    const token = Token.get(this.props.id)
    if (token) {
      this.rejoin(token)
    } else {
      this.joinForFirstTime()
    }
  }

  rejoin(token) {
    this.authenticate({
      token: token,
      name: null
    })
  }

  joinForFirstTime() {
    const name = prompt('What is your name?')
    if (!name) return
    this.authenticate({
      name: name,
      token: null
    })
  }

  authenticate(payload) {
    const game_id = this.props.id
    const self = this
    this.props.channel.push('join_as_player', payload)
      .receive('ok', (response) => {
        if (response.error) {
          console.error(response.error)
        } else {
          Token.set(game_id, response.token)
          self.setState({ playerId: response.player_id })
        }
      })
  }

  cancelMove(event) {
    this.setState({ movingTo: false })
    event.preventDefault()
  }

  submitMove(unitCount) {
    this.action('move', {
      from_id: this.state.selectedTileId,
      to_id: this.state.movingTo,
      count: parseInt(unitCount)
    })
    this.cancelSelection()
  }

  render() {
    return (
      <div className="Game">
        {this.state.winner_id &&
          <div className="Modal GameOver">
            {this.state.players[this.state.winner_id].name} wins!
          </div>
        }
        {this.state.movingTo &&
          <MoveForm maxUnits={this.state.tiles[this.state.selectedTileId].units - 1}
                    cancelMove={this.cancelMove.bind(this)}
                    submitMove={this.submitMove.bind(this)}
          />
        }
        <div className="Display">
          <h1 className="Logo">
            <a href="/"><img src={window.logo_src} alt="Sengoku" /></a>
          </h1>
          {this.state.players &&
            <Players players={this.state.players} currentPlayerId={this.state.current_player_id} />
          }
          {this.state.turn > 0 &&
            <button className="Button" onClick={this.endTurn.bind(this)}>End Turn</button>
          }
          {this.state.turn == 0 && this.canJoinGame() &&
            <button className="Button" onClick={this.joinAsPlayer.bind(this)}>Join Game</button>
          }
          {this.state.turn == 0 &&
            <button className="Button" onClick={this.startGame.bind(this)}>Start Game</button>
          }
        </div>
        {this.state.tiles &&
          <Board board={this.state.board}
                 tiles={this.state.tiles}
                 regions={this.state.regions}
                 players={this.state.players}
                 tileClicked={this.tileClicked.bind(this)}
                 cancelSelection={this.cancelSelection.bind(this)}
                 selectedTileId={this.state.selectedTileId} />
        }
      </div>
    )
  }
}

export default Game
