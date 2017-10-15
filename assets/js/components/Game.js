import React from 'react'
import ReactDOM from 'react-dom'
import { Socket } from 'phoenix'
import Board from './Board'
import Players from './Players'
import playerUI from '../playerUI'

class Game extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      selectedTileId: null,
    }
  }

  componentDidMount() {
    const self = this;
    this.props.channel.on('update', new_state => {
      self.setState(new_state)
    })
    if (this.canJoinGame()) this.joinAsPlayer()
  }

  token() {
    return localStorage.getItem('games:' + this.props.id + ':token')
  }

  canJoinGame() {
    return !this.token()
  }

  tileClicked(id, e) {
    console.log('tileClicked', id)
    const player_owns_tile =
      this.state.tiles[id].owner == this.state.current_player_id

    if (this.state.selectedTileId) {
      // Moving or attacking
      if (player_owns_tile && this.state.selectedTileId !== id) {
        // Moving
        const maxMovableUnits = this.state.tiles[this.state.selectedTileId].units - 1
        const unitCount = prompt('How many units do you wish to move? (Max: ' + maxMovableUnits + ') This will end your turn.')
        this.action('move', {
          from_id: this.state.selectedTileId,
          to_id: id,
          count: parseInt(unitCount)
        })
        this.cancelSelection()
        e.stopPropagation()
      } else if (this.state.selectedTileId !== id) {
        // Attacking
        this.action('attack', { from_id: this.state.selectedTileId, to_id: id })
        e.stopPropagation()
      }
    } else {
      if (player_owns_tile) {
        if (this.state.players[this.state.current_player_id].unplaced_units > 0) {
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
    this.setState({ selectedTileId: null })
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
    const name = prompt('What is your name?')
    if (!name) return
    const payload = {
      name: name,
      token: this.token()
    }
    const game_id = this.props.id
    this.props.channel.push('join_as_player', payload)
      .receive('ok', (response) => {
        if (response.error) {
          console.error(response.error)
        } else {
          localStorage.setItem('games:' + game_id + ':token', response.token)
        }
      })
  }

  render() {
    return (
      <div className="Game">
        {this.state.winner_id &&
          <div className="Overlay">
            {this.state.players[this.state.winner_id].name || 'Player ' + this.state.winner_id} wins!
          </div>
        }
        <div className="Display">
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
          <Board tiles={this.state.tiles}
                 regions={this.state.regions}
                 tileClicked={this.tileClicked.bind(this)}
                 cancelSelection={this.cancelSelection.bind(this)}
                 selectedTileId={this.state.selectedTileId} />
        }
      </div>
    )
  }
}

export default Game
