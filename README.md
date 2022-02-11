# SquidGame.jl
Strategy simulation for simple games.

## Example Prisoner Game
```julia
using SquidGame
import SquidGame._run_strategy

number_of_rounds = 10
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