import React from 'react'
import playerUI from '../playerUI'

const Player = (props) => {
  const styles = {
    backgroundColor: playerUI[props.id].color,
  }

  return (
    <li className={props.selected ? 'Player Player--active' : 'Player'} style={styles}>
      <span>
        <b>{playerUI[props.id].name}</b>
      </span>: {props.unplacedArmies} armies
    </li>
  )
}

export default Player
