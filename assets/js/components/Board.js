import React from 'react'
import boardData from '../boardData'

const Board = (props) => {
  const selectedNeighbors = props.selectedTileId && props.tiles[props.selectedTileId].neighbors
  const regionIds = Object.keys(props.regions).map(Number)

  const regions = regionIds.map((regionId) => {
    const region = props.regions[regionId]
    return (
      <g key={regionId}
         filter="url(#groupoutline)"
         children={region.tile_ids.map((tileId) => {
          const data = props.tiles[tileId]
          const tile = boardData[props.board][tileId]
          const is_selected = props.selectedTileId == tileId
          const neighbor_of_selected = selectedNeighbors && selectedNeighbors.indexOf(tileId) > -1
          let borderClassNames = ['Tile-border']
          is_selected && borderClassNames.push('Tile-border--major')
          neighbor_of_selected && borderClassNames.push('Tile-border--minor')

          return (
            <g key={tileId}
               className="Tile"
               transform={tile.translate}
               fill={data.owner && props.players[data.owner].color || '#d4c098'}
               onClick={(e) => props.tileClicked(tileId, e)}>

              <g className="Tile-background">{tile.path}</g>
              <clipPath id={'clip-path-' + tileId}>{tile.path}</clipPath>
              <g className={borderClassNames.join(' ')} clipPath={'url(#clip-path-' + tileId + ')'} fill="transparent" dWidth="5">{tile.path}</g>
              {data.units > 0 &&
                <text className="Tile-count"
                      stroke="none"
                      x={tile.tx}
                      y={tile.ty}
                      textAnchor="middle">{data.units}</text>
              }
              <g className="Tile-highlight">{tile.path}</g>
            </g>
          )
         })}
      />
    )
  })

  return (
    <svg className="Board" onClick={props.cancelSelection} viewBox="0 0 800 500" version="1.1" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <filter id="groupoutline">
          <feMorphology in="SourceGraphic" operator="dilate" radius="1"/>
          <feColorMatrix values="0 0 0 0 0
                                 0 0 0 0 0
                                 0 0 0 0 0
                                 0 0 0 1 0"/>
          <feMerge>
            <feMergeNode />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>
      </defs>
      <g stroke="none"
         fill="none"
         fillRule="evenodd"
         children={regions}
      />
    </svg>
  )
}

export default Board
