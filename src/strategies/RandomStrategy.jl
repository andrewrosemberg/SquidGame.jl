export RandomStrategy

abstract type RandomStrategy <: Strategy end

function _run_strategy(::Type{RandomStrategy}, reward::AbstractArray{Float64},
    history::Union{NamedTuple{(:my_action, :their_action, :my_reward, :their_reward), Tuple{Vector{Int64}, Matrix{Int64}, Vector{Float64}, Matrix{Float64}}}, Missing},
    rounds_left::Union{Int,  Missing}
)
    if !ismissing(history) && all(sum(history.my_reward) .> sum(history.their_reward, dims=1))
        println("You are all losing to a random bot")
    end
    return rand(1:size(reward,1))
end

push!(AVAILABLE_STRATEGIES, RandomStrategy)
