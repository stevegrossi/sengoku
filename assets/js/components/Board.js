import React from 'react'
import boardData from '../boardData'
import colors from '../colors'

const Board = (props) => {
  const neighbors = props.selectedTerritoryId && props.territories[props.selectedTerritoryId].neighbors
  const territories = Object.keys(props.territories).map(Number).map((id) => {
    const data = props.territories[id]
    const tile = boardData[id]
    const is_selected = props.selectedTerritoryId == id
    const neighbor_of_selected = neighbors && neighbors.indexOf(id) > -1

    return (
      <g key={id}
         transform={tile.translate}
         fill={colors[data.owner] || '#fff'}
         stroke="#000"
         onClick={(e) => props.territoryClicked(id, e)}
         strokeWidth={is_selected ? '1.5' : '0.75'}
         opacity={neighbor_of_selected ? '0.5' : '1'}>

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
    <svg onClick={props.cancelSelection} viewBox="0 0 415 251" version="1.1" xmlns="http://www.w3.org/2000/svg">
      <g id="japan"
         stroke="none"
         strokeWidth="1"
         fill="none"
         fillRule="evenodd"
         children={territories}>
      </g>
    </svg>
  )
}

export default Board
