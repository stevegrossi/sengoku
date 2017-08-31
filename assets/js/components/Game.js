import React from 'react'
import ReactDOM from 'react-dom'
import { Socket } from 'phoenix'
import Board from './Board'
import Players from './Players'

class Game extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      selectedTerritoryId: null,
    }
  }

  componentDidMount() {
    const self = this;
    this.props.channel.on('update', new_state => {
      self.setState(new_state)
    })
  }

  territoryClicked(id, e) {
    console.log('territoryClicked', id)
    const player_owns_territory =
      this.state.territories[id].owner == this.state.current_player_id

    if (player_owns_territory) {
      if (this.state.players[this.state.current_player_id].unplaced_armies > 0) {
        // Army placement phase
        this.action('place_armies', { count: 1, territory: id })
        e.stopPropagation()
      } else if (!this.state.selectedTerritoryId) {
        // Preparing to attack/move
        console.log('selecting territory', id)
        this.setState({ selectedTerritoryId: id })
        e.stopPropagation()
      }
    } else {
      // Attacking
      if (this.state.selectedTerritoryId) {
        this.action('attack', { from: this.state.selectedTerritoryId, to: id })
        e.stopPropagation()
      }
    }
  }

  cancelSelection() {
    this.setState({ selectedTerritoryId: null })
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

  render() {
    return (
      <div>
        {this.state.players &&
          <Players players={this.state.players} currentPlayerId={this.state.current_player_id} />
        }
        {this.state.territories &&
          <Board territories={this.state.territories}
                 territoryClicked={this.territoryClicked.bind(this)}
                 cancelSelection={this.cancelSelection.bind(this)}
                 selectedTerritoryId={this.state.selectedTerritoryId} />
        }
        <button onClick={this.endTurn.bind(this)}>End Turn</button>
        <h2>State</h2>
        <pre>
          {JSON.stringify(this.state, null, 2)}
        </pre>
      </div>
    )
  }
}

export default Game
