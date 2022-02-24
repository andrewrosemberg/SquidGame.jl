
# Examples

## Example Prisoner Game
```julia
using SquidGame
import SquidGame._run_strategy
using Plots

number_of_rounds = 10

# Define Game
# (The infrastructure is generic enough so you can have different rewards per iteration).
prisoner_game = prisoner(number_of_rounds) # same as `Game(; rewards=(iter) -> [[5. 0]; [10 2]], number_of_rounds)`


# Define a name for your strategy
abstract type MyStrategy <: Strategy end

# Define the logic of your strategy
function SquidGame._run_strategy(::Type{MyStrategy}, reward::AbstractArray{Float64}, 
    history::Union{NamedTuple{(:my_action, :their_action, :my_reward, :their_reward), Tuple{Vector{Int64}, Matrix{Int64}, Vector{Float64}, Matrix{Float64}}}, Missing},
    rounds_left::Union{Int,  Missing}
)
    
    # your can use whatever logic you wish. This example is an angel, it will always choose the cooperative action.
    return find_cooperative_action(reward)
end

strategies = Vector{Type{<:Strategy}}()

# push it to the stage
push!(strategies, MyStrategy)

# Push your opponent 
push!(strategies, Devil)

# Simulate the game.
realized_reward_history, strategies_action_history = play_game(prisoner_game, strategies)

# Visualise the scores over all rounds 
scoreboard(realized_reward_history, strategies)
```
![](docs/src/assets/prisoner_game_plot.png)

## Play a game with 3 players

```julia 
# add a player 
push!(strategies, RandomStrategy)

# choose the game
random_game = randgame(number_of_rounds)

realized_reward_history, strategies_action_history = play_game(random_game, strategies)
```