import React from 'react'
import boardData from '../boardData'

const Board = (props) => {

  const fills = {
    1: 'red',
    2: 'green',
    3: 'blue',
    4: 'yellow',
  }

  const territories = Object.keys(props.territories).map((id) => {
    const data = props.territories[id]
    const tile = boardData[id]
    return (
      <g key={id}
         transform={tile.translate}
         fill={fills[data.owner] || '#fff'}
         stroke="#000"
         strokeWidth="0.75">

        {tile.path}

        <text className="Territory-count"
              stroke="none"
              x={tile.tx}
              y={tile.ty}
              textAnchor="middle">{data.armies}</text>
      </g>
    )
  })

  return (
    <svg viewBox="0 0 415 251" version="1.1" xmlns="http://www.w3.org/2000/svg">
      <g id="japan" stroke="none" strokeWidth="1" fill="none" fillRule="evenodd">
        {territories}
      </g>
    </svg>
  )
}

export default Board
