defmodule Sengoku.Authentication do
  @moduledoc """
  Responible for token-based authentication to determine which human players
  correspond to which integer player IDs in the GameServer’s state.
  """

  alias Sengoku.{Player, Token}

  def initialize_state(state) do
    Map.put(state, :tokens, %{})
  end

  def authenticate_player(state, token, name) do
    existing_player_id = state.tokens[token]

    if existing_player_id do
      {:ok, {existing_player_id, token}, state}
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
            |> put_in([:tokens, token], first_available_player_id)
            |> Player.update_attributes(first_available_player_id, %{ai: false, name: name})

          {:ok, {first_available_player_id, token}, state}
        end
      else
        {:error, :in_progress}
      end
    end
  end
end
