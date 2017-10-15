defmodule Sengoku.Authentication do
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
          |> Player.ai_ids
          |> List.first

        if is_nil(first_available_player_id) do
          {:error, :full}
        else
          new_token = Token.new(16)
          state =
            state
            |> put_in([:tokens, new_token], first_available_player_id)
            |> Player.update_attributes(first_available_player_id, %{ai: false, name: name})
          {:ok, {first_available_player_id, new_token}, state}
        end
      else
        {:error, :in_progress}
      end
    end
  end
end
