import React from 'react'
import playerUI from '../playerUI'

const Player = (props) => {
  const styles = {
    backgroundColor: playerUI[props.id].color,
  }

  let classNames = ['Player']
  if (props.current) classNames.push('Player--current')
  if (!props.active) classNames.push('Player--inactive')

  return (
    <li className={classNames.join(' ')} style={styles}>
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
