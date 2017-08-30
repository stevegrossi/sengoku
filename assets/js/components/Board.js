import React from 'react'

const Board = (props) => {
  const territories = Object.keys(props.territories).map((id) => {
    const data = props.territories[id]
    return (
      <li key={id}>
        <code>{JSON.stringify(data)}</code>
      </li>
    )
  })
  return (
    <ol>{territories}</ol>
  )
}

export default Board
