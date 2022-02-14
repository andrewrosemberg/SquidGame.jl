# SquidGame.jl
Strategy simulation for simple games.

Using function `play_game`, simulates a game for of `N` strategies competing against each other (where `N` is the appropriate number of players for the game).

Implementable games are "deterministic" games where each player knows the possible rewards for each round at decision time, with the only uncertainty being the action of other players.

Rewards are defined as a multi-dimentional array where entries your action is the first index and rivals are the remaining indexes. For example, a 2 player game:

|               | Rival Action 1| Rival Action 2|
| ------------- | ------------- | ------------- |
| Your Action 1 |      5.0      |      0.0      |
| Your Action 2 |      10.0     |      2.0      |

In this case:
 - If you acted with action `1` and your rival also acted if `1`, both would have earned `5.0` point; 

## Example Prisoner Game
```julia
using SquidGame
import SquidGame._run_strategy

number_of_rounds = 10

# Define Game
# (The infrastructure is generic enough so you can have different rewards per iteration).
prisoner_game = prisoner(number_of_rounds) # same as `Game(; rewards=(iter) -> [[5. 0]; [10 2]], number_of_rounds)`

strategies = Vector{Type{<:Strategy}}()

# Define your strategy name
abstract type MyStrategy <: Strategy end

# Define it's logic
function SquidGame._run_strategy(::Type{MyStrategy}, reward::AbstractArray{Float64}, 
    history::Union{NamedTuple{(:my_action, :their_action, :my_reward, :their_reward), Tuple{Vector{Int64}, Matrix{Int64}, Vector{Float64}, Matrix{Float64}}}, Missing},
    rounds_left::Union{Int,  Missing}
)
    
    # your can use whatever logic you wish but this example is an angel so it will try to always cooperate
    return find_cooperative_action(reward)
end

# push it to the stage
push!(strategies, MyStrategy)

# Push your oponent 
push!(strategies, Devil)

# Simulate the batle
realized_reward_history, strategies_action_history = play_game(prisoner_game, strategies)
```