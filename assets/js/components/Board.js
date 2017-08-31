import React from 'react'
import boardData from '../boardData'
import colors from '../colors'

const Board = (props) => {
  const territories = Object.keys(props.territories).map(Number).map((id) => {
    const data = props.territories[id]
    const tile = boardData[id]
    return (
      <g key={id}
         transform={tile.translate}
         fill={colors[data.owner] || '#fff'}
         stroke="#000"
         onClick={() => props.selectTerritory(id)}
         strokeWidth={props.selectedTerritoryId == id ? '1.5' : '0.75'}>

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
