defmodule Sengoku.Battle do
  @moduledoc """
  Responsible for the logic of one Player attacking another’s neighboring Tile.
  """

  defstruct attacking_tile: nil, defending_tile: nil   

  alias Sengoku.Tile

  # I think it might be better to decide if the battle is valid (neighboring tiles, sufficient units, etc.)
  # Before we get to the guts of the battle

  # if attacking_units > 0 and
  # from_tile.owner == current_player_id and
  # defender_id != current_player_id and
  # to_id in from_tile.neighbors and
  # is_nil(state.required_move)

  def begin(%{current_player_id: current_player_id} = state, from_id, to_id) do
    battle = %Battle{attacking_tile: Tile.get(state, from_id), defending_tile: Tile.get(state, to_id)}
  end  

  def decide(%Battle{attacking_tile: attacking_tile, defending_tile: defending_tile}) do
    attacker_rolls =
    attacking_tile.units - 1
    |> min(3)
    |> roll_n_times

    defender_rolls =
    defending_tile.units
    |> min(2)
    |> roll_n_times

    compare_rolls(attacker_rolls, defender_rolls)
  end

  def resolve(battle_outcome)
    {attacker_losses, defender_losses} =
    battle_outcome || Battle.decide(attacking_units, defending_units)

    state
    |> Tile.adjust_units(from_id, -attacker_losses)
    |> Tile.adjust_units(to_id, -defender_losses)
    |> check_for_capture(from_id, to_id, min(attacking_units, 3))
    |> deactivate_player_if_defeated(defender_id)
    |> check_for_winner()
    else
    Logger.info("Invalid attack from `#{from_id}` to `#{to_id}` by player `#{current_player_id}`")
    state
  end

  defp check_for_capture(state, from_id, to_id, attacking_units) do
    if state.tiles[to_id].units == 0 do
      movable_units = state.tiles[from_id].units - 1
      if movable_units > attacking_units do
        state
        |> Tile.set_owner(to_id, state.current_player_id)
        |> Tile.adjust_units(to_id, 0)
        |> Map.put(:required_move, %{
            from_id: from_id,
            to_id: to_id,
            min: 3,
            max: movable_units
          })
      else
        state
        |> Tile.adjust_units(from_id, -attacking_units)
        |> Tile.set_owner(to_id, state.current_player_id)
        |> Tile.adjust_units(to_id, attacking_units)
      end
    else
      state
    end
  end

  def compare_rolls(a_rolls, d_rolls) do
    compare_rolls(a_rolls, d_rolls, {0, 0})
  end
  def compare_rolls([], _d_rolls, losses) do
    losses
  end
  def compare_rolls(_a_rolls, [], losses) do
    losses
  end
  def compare_rolls([a_hd | a_tl], [d_hd | d_tl], {a_losses, d_losses})
    when a_hd > d_hd do
    compare_rolls(a_tl, d_tl, {a_losses, d_losses + 1})
  end
  def compare_rolls([a_hd | a_tl], [d_hd | d_tl], {a_losses, d_losses})
    when a_hd <= d_hd do
    compare_rolls(a_tl, d_tl, {a_losses + 1, d_losses})
  end

  defp roll_n_times(n) do
    1..n
    |> Enum.map(&roll_die/1)
    |> Enum.sort(&(&1 >= &2))
  end

  defp roll_die(_i) do
    :rand.uniform(6)
  end
end
