# Sengoku

Unite feudal Japan in this Risk-like strategy game! (This is extremely alpha and in active development.)

![a screenshot of the game map](https://github.com/stevegrossi/sengoku/raw/master/screenshot.png)

## Gameplay

Up to 8 players: play against friends online, the computer, or both.

- Provinces are randomly divided amongst all players at the start of the game.
- Each player receives one unit for every 3 provinces they hold (with a minimum of 3) at the start of each turn.
- Receive bonus units for holding all provinces within a marked region.
- On your turn you may attack neighboring provinces (see below).
- At the end of your turn, you may move units from one of your provinces to one of its neighbors you control.
- A player is defeated when they no longer control any provinces.
- A player wins when all other players are defeated.

### Rules for Battle

- Up to 3 units will attack at once, and up to 2 units will defend. A six-sided die is rolled for each.
- Rolls are sorted from highest to lowest and paired off: e.g. the highest attacker roll with the highest defender roll. Defending units win ties. The losing unit is removed from play.
- If all defending units are removed, the attacker takes control of that province and their number of attacking units moves in.

## Development

To start your Phoenix server:

  * Setup the project with `mix setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser to play!

### AI Development

Want to improve the AI? Great! Computer players implement the `Sengoku.AI` behaviour. The current AI is the `Sengoku.AI.Smart` module.

1. Copy the current AI module and its tests. From the command line:

    ```
    cp lib/sengoku/ai/smart.ex lib/sengoku/ai/smarter.ex
    cp test/sengoku/ai/smart_test.exs test/sengoku/ai/smarter_test.exs
    ```

2. I’d like to automate this, but with `lib/sengoku/ai/smarter.ex` manually rename `Sengoku.AI.Smart` to `Sengoku.AI.Smarter`, and within `test/sengoku/ai/smarter_test.exs` rename `Sengoku.AI.SmartTest` to `Sengoku.AI.SmarterTest`.
3. Run `mix test` to ensure everything’s working.
4. Run `mix ai.arena Sengoku.AI.Smarter` with your new AI module:

    ```
    Starting 2000 games with Sengoku.AI.Smarter as Player 1
    against Sengoku.AI.Smart as all other players

     Player                         | Win %
    --------------------------------|-------
     1 (Sengoku.AI.Smarter)         |  11.9%
     2 (Sengoku.AI.Smart)           |  11.8%
     3 (Sengoku.AI.Smart)           |  13.6%
     4 (Sengoku.AI.Smart)           |  13.7%
     5 (Sengoku.AI.Smart)           |  12.4%
     6 (Sengoku.AI.Smart)           |  12.3%
     7 (Sengoku.AI.Smart)           |  11.5%
     8 (Sengoku.AI.Smart)           |  12.8%
    ```

    (With `mix ai.arena`, at least on the default `"westeros"` map, win percentages should be even within a few percentage points.)

5. Now change how `Sengoku.AI.Smarter` works! Continue running `mix ai.arena Sengoku.AI.Smarter` to test the impact of your changes against the default AI.
6. When you’ve made an improvement, merge your changes back into `Sengoku.AI.Smart` and consider opening a Pull Request with the improvements!
