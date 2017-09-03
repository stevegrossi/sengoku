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
  }

  tileClicked(id, e) {
    console.log('tileClicked', id)
    const player_owns_tile =
      this.state.tiles[id].owner == this.state.current_player_id

    if (player_owns_tile) {
      if (this.state.players[this.state.current_player_id].unplaced_armies > 0) {
        // Army placement phase
        this.action('place_army', { tile_id: id })
        e.stopPropagation()
      } else if (!this.state.selectedTileId) {
        // Preparing to attack/move
        console.log('selecting tile', id)
        this.setState({ selectedTileId: id })
        e.stopPropagation()
      }
    } else {
      // Attacking
      if (this.state.selectedTileId) {
        this.action('attack', { from_id: this.state.selectedTileId, to_id: id })
        e.stopPropagation()
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

  canStartGame() {
    return Object.values(this.state.players).filter((player) => player.active).length > 1
  }

  render() {
    return (
      <div>
        {this.state.players &&
          <Players players={this.state.players} currentPlayerId={this.state.current_player_id} />
        }
        {this.state.winner_id &&
          <div className="Overlay">
            {playerUI[this.state.winner_id].name} wins!
          </div>
        }
        {this.state.tiles &&
          <Board tiles={this.state.tiles}
                 tileClicked={this.tileClicked.bind(this)}
                 cancelSelection={this.cancelSelection.bind(this)}
                 selectedTileId={this.state.selectedTileId} />
        }
        {this.state.turn == 0 &&
          <button disabled={!this.canStartGame()} onClick={this.startGame.bind(this)}>Start Game</button>
        }
        {this.state.turn > 0 &&
          <button onClick={this.endTurn.bind(this)}>End Turn</button>
        }
      </div>
    )
  }
}

export default Game
