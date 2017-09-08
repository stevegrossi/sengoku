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
        <span>
          {props.unplacedArmies}
          <svg className="Icon" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg" version="1.1" >
            <use href="#icon-unit" />
          </svg>
        </span>
      }
    </li>
  )
}

export default Player
