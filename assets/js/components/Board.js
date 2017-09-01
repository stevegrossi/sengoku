import React from 'react'
import boardData from '../boardData'
import playerUI from '../playerUI'

const Board = (props) => {
  const neighbors = props.selectedTileId && props.tiles[props.selectedTileId].neighbors
  const tiles = Object.keys(props.tiles).map(Number).map((id) => {
    const data = props.tiles[id]
    const tile = boardData[id]
    const is_selected = props.selectedTileId == id
    const neighbor_of_selected = neighbors && neighbors.indexOf(id) > -1

    return (
      <g key={id}
         transform={tile.translate}
         fill={playerUI[data.owner] && playerUI[data.owner].color || '#fff'}
         stroke="#000"
         onClick={(e) => props.tileClicked(id, e)}
         strokeWidth={is_selected ? '1.5' : '0.75'}
         opacity={neighbor_of_selected ? '0.5' : '1'}>

        {tile.path}

        <text className="Tile-count"
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
         children={tiles}>
      </g>
    </svg>
  )
}

export default Board
