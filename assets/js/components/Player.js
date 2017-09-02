import React from 'react'
import playerUI from '../playerUI'

const Player = (props) => {
  const styles = {
    backgroundColor: playerUI[props.id].color,
  }

  const classNames = [
    'Player',
    props.current && 'Player--current',
    props.active || 'Player--inactive'
  ].join(' ')

  return (
    <li className={classNames} style={styles}>
      <b>{playerUI[props.id].name}</b>
      {props.active &&
        <span>{props.unplacedArmies} 兵</span>
      }
    </li>
  )
}

export default Player
