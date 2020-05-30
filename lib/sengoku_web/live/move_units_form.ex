defmodule SengokuWeb.MoveUnitsForm do
  use Phoenix.LiveComponent

  @impl true
  def update(%{required_move: %{min: min, max: max}} = assigns, socket) do
    default_count = midpoint(min, max)
    {:ok, assign(socket, Map.merge(assigns, %{count: default_count}))}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="Modal">
      <div class="MoveForm">
        <h2>Move how many?</h2>
        <form
          class="MoveForm-slider"
          phx-change="update_count"
          phx-target="<%= @myself %>"
        >
          <span><%= @required_move.min %></span>
          <input class="MoveForm-input"
                 type="range"
                 min=<%= @required_move.min %>
                 max=<%= @required_move.max %>
                 name="count"
                 value="<%= @count %>"
                 autofocus
          />
          <span><%= @required_move.max %></span>
        </form>
        <div class="MoveForm-actions">
          <button
            class="Button Button--primary"
            phx-click="move"
            phx-value-count="<%= @required_move.max %>"
          >Move Max (<%= @required_move.max %>)</button>
          <button
            class="Button Button--primary"
            phx-click="move"
            phx-value-count="<%= @count %>"
          >Move Selected (<%= @count %>)</button>
          <button
            class="Button Button--primary"
            phx-click="move"
            phx-value-count="<%= @required_move.min %>"
          >Move Min (<%= @required_move.min %>)</button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("update_count", %{"count" => count_string}, socket) do
    {count, _} = Integer.parse(count_string)
    {:noreply, assign(socket, count: count)}
  end

  defp midpoint(low, high) do
    low + floor((high - low) / 2)
  end
end
