defmodule Sengoku.Authentication do
  @moduledoc """
  Responible for determining and recording which human players (identified by a
  unique player_id) correspond to which integer player numbers in the
  GameServer’s state.
  """

  alias Sengoku.Player

  def initialize_state(state) do
    Map.put(state, :player_ids, %{})
  end

  def authenticate_player(state, player_id, name) do
    existing_player_id = state.player_ids[player_id]

    if existing_player_id do
      {:ok, {existing_player_id, player_id}, state}
    else
      if state.turn == 0 do
        first_available_player_id =
          state
          |> Player.ai_ids()
          |> List.first()

        if is_nil(first_available_player_id) do
          {:error, :full}
        else
          state =
            state
            |> put_in([:player_ids, player_id], first_available_player_id)
            |> Player.update_attributes(first_available_player_id, %{ai: false, name: name})

          {:ok, {first_available_player_id, player_id}, state}
        end
      else
        {:error, :in_progress}
      end
    end
  end
end
