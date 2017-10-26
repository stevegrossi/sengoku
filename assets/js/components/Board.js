import React from 'react'
import Region from './Region'
import boardData from '../boardData'

const Board = (props) => {
  const selectedNeighbors = props.selectedTileId && props.tiles[props.selectedTileId].neighbors

  const regions = Object.keys(props.regions).map(Number).map((regionId) => {
    return (
      <Region key={regionId}
              tileIds={props.regions[regionId].tile_ids}
              tiles={props.tiles}
              board={props.board}
              tileClicked={props.tileClicked}
              selectedTileId={props.selectedTileId}
              players={props.players}
              selectedNeighbors={selectedNeighbors}
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
        {boardData[props.board].defs}
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
