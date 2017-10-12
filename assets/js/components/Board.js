import React from 'react'
import boardData from '../boardData'
import playerUI from '../playerUI'

const tileCountFill = (ownerId) => {
  return ownerId && playerUI[ownerId] && playerUI[ownerId].color || '#d4c098'
}

const Board = (props) => {
  const regions = Object.values(props.regions)
  const regionIds = Object.keys(props.regions)
  const regionIdForTile = (tileId) => {
    for (let i = 0; i < regions.length; i++) {
      const tile_index = regions[i].tile_ids.indexOf(tileId)
      if (tile_index > -1) return regionIds[i]
    }
  }

  const neighbors = props.selectedTileId && props.tiles[props.selectedTileId].neighbors
  const tiles = Object.keys(props.tiles).map(Number).map((id) => {
    const data = props.tiles[id]
    const tile = boardData[id]
    const is_selected = props.selectedTileId == id
    const neighbor_of_selected = neighbors && neighbors.indexOf(id) > -1
    let borderClassNames = ['Tile-border']
    is_selected && borderClassNames.push('Tile-border--major')
    neighbor_of_selected && borderClassNames.push('Tile-border--minor')

    return (
      <g key={id}
         className={'Tile Region--' + regionIdForTile(id)}
         transform={tile.translate}
         onClick={(e) => props.tileClicked(id, e)}>

        <g>{tile.path}</g>
        <clipPath id={'clip-path-' + id}>{tile.path}</clipPath>
        <g className={borderClassNames.join(' ')} clipPath={'url(#clip-path-' + id + ')'} fill="transparent" strokeWidth="5" stroke="rgba(255,255,255,.5)">{tile.path}</g>
        <g>
          <circle cx={tile.tx}
                  cy={tile.ty - 3}
                  r="6"
                  fill={tileCountFill(data.owner)} />
          <text className="Tile-count"
                stroke="none"
                x={tile.tx}
                y={tile.ty}
                textAnchor="middle">{data.units}</text>
        </g>
        <g className="Tile-highlight">{tile.path}</g>
      </g>
    )
  })

  return (
    <svg className="Board" onClick={props.cancelSelection} viewBox="0 0 415 251" version="1.1" xmlns="http://www.w3.org/2000/svg">
      <g id="japan"
         stroke="none"
         strokeWidth="1"
         fill="none"
         fillRule="evenodd"
         children={tiles} />
    </svg>
  )
}

export default Board
