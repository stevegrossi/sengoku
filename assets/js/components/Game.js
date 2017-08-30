import React from "react"
import ReactDOM from "react-dom"

class Game extends React.Component {
  render() {
    return (
      <div>Hi from React! This is Game {this.props.id}</div>
    )
  }
}

export default Game
