import React from 'react'
import ReactDOM from 'react-dom'
import { Socket } from 'phoenix'
import Board from './Board'
import Players from './Players'

class Game extends React.Component {
  constructor(props) {
    super(props)
    this.state = {}
  }

  componentDidMount() {
    const self = this;
    this.props.channel.on('update', new_state => {
      self.setState(new_state)
    })
  }

  action(type, payload) {
    payload = payload || {}
    payload.type = type
    console.log('action', payload)
    this.props.channel.push('action', payload)
  }

  endTurn() {
    this.action('end_turn')
  }

  placeArmy() {
    this.action('place_armies', { count: 1, territory: 1 })
  }

  render() {
    return (
      <div>
        {this.state.players &&
          <Players players={this.state.players} />
        }
        {this.state.territories &&
          <Board territories={this.state.territories} />
        }
        <button onClick={this.endTurn.bind(this)}>End Turn</button>
        <button onClick={this.placeArmy.bind(this)}>Place Army</button>
        <h2>State</h2>
        <pre>
          {JSON.stringify(this.state, null, 2)}
        </pre>
      </div>
    )
  }
}

export default Game
