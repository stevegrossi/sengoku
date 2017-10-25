import React from 'react'

class MoveForm extends React.Component {

  constructor(props) {
    super(props)
    this.state = {
      value: props.maxUnits
    }
  }

  handleSubmit(event) {
    this.props.submitMove(this.state.value);
    event.preventDefault()
  }

  handleChange(event) {
    this.setState({ value: event.target.value })
  }

  halfMaxUnits() {
    return Math.floor(this.props.maxUnits / 2)
  }

  moveHalf(event) {
    this.props.submitMove(this.halfMaxUnits())
    event.preventDefault()
  }

  render() {
    return (
      <div className="Modal">
        <form className="MoveForm" onSubmit={this.handleSubmit.bind(this)}>
          <h2>Move how many?</h2>
          <div className="MoveForm-slider">
            <span>0</span>
            <input className="MoveForm-input"
                   type="range"
                   min={0}
                   max={this.props.maxUnits}
                   value={this.state.value}
                   onChange={this.handleChange.bind(this)}
                   autoFocus
            />
            <span>{this.props.maxUnits}</span>
          </div>
          <div className="MoveForm-actions">
            <input className="Button Button--primary"
                   type="submit"
                   value={'Move ' + this.state.value}
            />
            <button className="Button Button--primary"
                    type="submit"
                    onClick={this.moveHalf.bind(this)}
            >
              Move {this.halfMaxUnits()} (half)
            </button>
            <button className="Button"
                    onClick={this.props.cancelMove}
                    children={'Cancel'}
            />
          </div>
        </form>
      </div>
    )
  }
}

export default MoveForm
