import React from 'react'

const borderClassName = (props) => {
  let classes = ['Tile-border']
  props.isSelected && classes.push('Tile-border--major')
  props.isNeighborOfSelected && classes.push('Tile-border--minor')
  return classes.join(' ')
}

const Tile = (props) => {
  return (
    <g className="Tile"
       transform={props.tile.translate}
       fill={props.data.owner && props.players[props.data.owner].color || '#d4c098'}
       onClick={(e) => props.tileClicked(props.id, e)}
    >
      <defs>
        {props.tile.path}
      </defs>
      <g className="Tile-background">
        <use xlinkHref={'#path-' + props.id} />
      </g>
      <clipPath id={'clip-path-' + props.id}>
        <use xlinkHref={'#path-' + props.id} />
      </clipPath>
      <g className={borderClassName(props)} clipPath={'url(#clip-path-' + props.id + ')'} fill="transparent">
        <use xlinkHref={'#path-' + props.id} />
      </g>
      {props.data.units > 0 &&
        <text className="Tile-count"
              stroke="none"
              x={props.tile.tx}
              y={props.tile.ty}
              textAnchor="middle">{props.data.units}</text>
      }
      <g className="Tile-highlight">
        <use xlinkHref={'#path-' + props.id} />
      </g>
    </g>
  )
}

export default Tile
