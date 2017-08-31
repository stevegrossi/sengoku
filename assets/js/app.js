import React from "react"
import ReactDOM from "react-dom"
import { Socket } from 'phoenix'
import Game from "./components/Game"

const game_id = window.game_id
const game_container = document.getElementById('game_container')
if (game_id && game_container) {
  const socket = new Socket('/socket', {params: {token: null}})
  socket.connect()
  const channel = socket.channel('games:' + game_id, {})
  channel.join()
    .receive('ok', resp => {
      console.log('Joined game ' + game_id, resp)
      ReactDOM.render(<Game id={game_id} channel={channel} />, game_container)
    })
    .receive('error', resp => { console.error('Unable to join game channel :(', resp) })
}
