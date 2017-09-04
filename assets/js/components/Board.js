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
         fill={playerUI[data.owner] && playerUI[data.owner].color || '#d4c098'}
         stroke="#000"
         onClick={(e) => props.tileClicked(id, e)}
         strokeWidth="0.75">

        {tile.path}
        <clipPath id={'clip-path-' + id}>{tile.path}</clipPath>
        {is_selected &&
          <g clipPath={'url(#clip-path-' + id + ')'} fill="transparent" strokeWidth="5" stroke="rgba(255,255,255,.5)">{tile.path}</g>
        }
        {neighbor_of_selected &&
          <g clipPath={'url(#clip-path-' + id + ')'} fill="transparent" strokeWidth="5" stroke="rgba(255,255,255,.25)">{tile.path}</g>
        }

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
