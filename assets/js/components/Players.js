import React from 'react'
import Player from './Player'

const Players = (props) => {

  const players = Object.keys(props.players).map(Number).map((player_id) => {
    return <Player key={player_id}
                   id={player_id}
                   selected={props.currentPlayerId == player_id}
                   unplacedArmies={props.players[player_id].unplaced_armies} />
  })

  return (
    <ul className="Players">
      {players}
    </ul>
  )
}

export default Players
