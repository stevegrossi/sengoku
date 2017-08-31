import React from 'react'
import colors from '../colors'

const Player = (props) => {
  const styles = {
    color: colors[props.id]
  }

  return (
    <li>
      <span style={styles}>
        {props.selected && <span>•</span>}
        Player {props.id}
      </span>: {props.unplacedArmies} armies
    </li>
  )
}

export default Player
