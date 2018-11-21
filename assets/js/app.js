import React from "react"
import ReactDOM from "react-dom"
import { Socket } from 'phoenix'
import Game from "./components/Game"
import css from '../css/app.scss'

const game_id = window.game_id
const game_container = document.getElementById('game_container')
if (game_id && game_container) {
  const socket = new Socket('/socket', {params: {}})
  socket.connect()

  const token = localStorage.getItem('games:' + game_id + ':token')
  const channel = socket.channel('games:' + game_id, { token: token })
  channel.join()
    .receive('ok', resp => {
      console.log('Joined game ' + game_id, resp)
      ReactDOM.render(<Game id={game_id} channel={channel} />, game_container)
    })
    .receive('error', resp => {
      if (resp.reason == 'in_progress') {
        game_container.innerHTML = 'You cannot join a game already in progress.'
      } else {
        game_container.innerHTML = 'An unexpected error occurred. Please try refreshing.'
      }
    })
}
