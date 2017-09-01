import React from 'react'
import colors from '../colors'

const Player = (props) => {
  const styles = {
    backgroundColor: colors[props.id],
  }

  return (
    <li className={props.selected ? 'Player Player--active' : 'Player'} style={styles}>
      <span>
        <b>Player {props.id}</b>
      </span>: {props.unplacedArmies} armies
    </li>
  )
}

export default Player
