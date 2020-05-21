defmodule SengokuWeb.MoveUnitsForm do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="Modal">
      <form class="MoveForm" phx-submit="move">
        <h2>Move how many?</h2>
        <div class="MoveForm-slider">
          <span><%= @required_move.min %></span>
          <input class="MoveForm-input"
                 type="range"
                 min=<%= @required_move.min %>
                 max=<%= @required_move.max %>
                 name="count"
                 autoFocus
          />
          <span><%= @required_move.max %></span>
        </div>
        <div class="MoveForm-actions">
          <input class="Button Button--primary" type="submit" value="Move" />
        </div>
      </form>
    </div>
    """
  end
end
