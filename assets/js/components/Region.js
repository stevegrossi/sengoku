import React from 'react'
import Tile from './Tile'
import boardData from '../boardData'

const Region = (props) => {
  return (
    <g filter="url(#groupoutline)"
     children={props.tileIds.map((tileId) =>
      <Tile key={tileId}
            id={tileId}
            data={props.tiles[tileId]}
            tile={boardData[props.board][tileId]}
            tileClicked={props.tileClicked}
            isSelected={props.selectedTileId == tileId}
            isNeighborOfSelected={props.selectedNeighbors && props.selectedNeighbors.indexOf(tileId) > -1}
            players={props.players}
      />
     )}
    />
  )
}

export default Region
