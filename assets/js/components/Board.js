import React from 'react'
import Tile from './Tile'
import boardData from '../boardData'

const Board = (props) => {
  const selectedNeighbors = props.selectedTileId && props.tiles[props.selectedTileId].neighbors
  const regionIds = Object.keys(props.regions).map(Number)

  const regions = regionIds.map((regionId) => {
    const region = props.regions[regionId]
    return (
      <g key={regionId}
         filter="url(#groupoutline)"
         children={region.tile_ids.map((tileId) =>
          <Tile key={tileId}
                id={tileId}
                data={props.tiles[tileId]}
                tile={boardData[props.board][tileId]}
                tileClicked={props.tileClicked}
                isSelected={props.selectedTileId == tileId}
                isNeighborOfSelected={selectedNeighbors && selectedNeighbors.indexOf(tileId) > -1}
                players={props.players}
          />
         )}
      />
    )
  })

  return (
    <svg className="Board" onClick={props.cancelSelection} viewBox="0 0 800 500" version="1.1" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <filter id="groupoutline">
          <feMorphology in="SourceGraphic" operator="dilate" radius="2"/>
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
