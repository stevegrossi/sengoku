const Token = {
  get: (gameId) => {
    return localStorage.getItem('games:' + gameId + ':token')
  },

  set: (gameId, token) => {
    localStorage.setItem('games:' + gameId + ':token', token)
  }
}

export default Token
