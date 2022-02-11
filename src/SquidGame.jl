module SquidGame

    using ProgressMeter
    using LinearAlgebra
    using Statistics

    export Strategy, Game, play_game
    export find_greedy_action, find_cooperative_action

    abstract type Strategy end

    AVAILABLE_STRATEGIES = Vector{Type{<:Strategy}}()
    AVAILABLE_GAMES = []

    function _run_strategy(::Type{<:Strategy}, reward::AbstractArray{Float64}, 
        history::Union{NamedTuple{(:my_action, :their_action, :my_reward, :their_reward), Tuple{Vector{Int64}, Matrix{Int64}, Vector{Float64}, Matrix{Float64}}}, Missing},
        rounds_left::Union{Int,  Missing}
    ) 
        @error "No Strategy Logic defined for this strategy"
    end

    struct Game
        rewards::Function # rewards(iter) -> SymmetricArray{Float64, num_players}
        num_rounds::Int
        num_players::Int
        show_rounds_left::Bool
    end

    function Game(; rewards, num_rounds, num_players=2, show_rounds_left=true)
        @assert num_players > 1
        if num_players == 2
            for iter in 1:num_rounds
                reward = rewards(iter)
                @assert (num_players, num_players) == size(reward)
            end
        else
            @warn "Check that your rewards are symmetric (we don't know how)."
        end
        return Game(rewards, num_rounds, num_players, show_rounds_left)
    end

    function find_greedy_action(reward)
        num_players = length(size(reward))
        return findmax(sum(reward, dims=2:num_players)[:, ones(Int, num_players-1)...])[2]
    end

    function find_cooperative_action(reward)
        num_players = length(size(reward))
        return findmax(x -> reward[fill(x, num_players)...], collect(1:num_players))[2]
    end

    function play_game(game::Game, strategies::Vector{Type{<:Strategy}})
        num_strategies = length(strategies)
        if game.num_players != num_strategies
            @error "Wrong number of players for the game."
        end

        realized_reward_history = Matrix{Float64}(undef, game.num_rounds, num_strategies)
        strategies_action_history = Matrix{Int64}(undef, game.num_rounds, num_strategies)
        @showprogress 1 "Computing rounds" for iter in 1:game.num_rounds
            reward = game.rewards(iter)
            for (s, strategy) in enumerate(strategies)
                if iter == 1
                    history_for_strategy_s = missing
                else
                    history_for_strategy_s = (; my_action = strategies_action_history[1:iter-1, s], 
                        their_action = strategies_action_history[1:iter-1, 1:end .!= s], my_reward = realized_reward_history[1:iter-1, s], their_reward=realized_reward_history[1:iter-1, 1:end .!= s]
                    )
                end
                action_s = _run_strategy(strategy, reward, 
                    history_for_strategy_s,
                    game.show_rounds_left ? game.num_rounds - iter + 1 : missing
                )
                
                if action_s > size(reward, 1) || action_s < 1
                    @error "Strategy $strategy is trying to cheating"
                end
                strategies_action_history[iter, s] = action_s
            end
        end
        for iter in 1:game.num_rounds, s in 1:length(strategies)
            reward = game.rewards(iter)
            realized_reward_history[iter, s] = reward[strategies_action_history[iter, s], strategies_action_history[iter, 1:end .!= s]...]
        end

        return realized_reward_history, strategies_action_history
    end

    strategies_dir = joinpath(dirname(@__FILE__), "strategies")
    for file in readdir(strategies_dir)
        include(joinpath(strategies_dir, file))
    end

    include("example_games.jl")
end