module SquidGame

    using ProgressMeter
    using LinearAlgebra
    using Statistics

    export Strategy, Game, play_game
    export find_greedy_action, find_cooperative_action

    abstract type Strategy end

    AVAILABLE_STRATEGIES = Vector{Type{<:Strategy}}()
    AVAILABLE_GAMES = []

    """
        _run_strategy(strategy::Type{<:Strategy}, reward::AbstractArray{Float64}, 
    history::Union{NamedTuple{(:my_action, :their_action, :my_reward, :their_reward), Tuple{Vector{Int64}, Matrix{Int64}, Vector{Float64}, Matrix{Float64}}}, Missing},
    rounds_left::Union{Int,  Missing}
    ) -> Int

    Returns the chosen action index for the specified strategy based on the next round `reward` and the `history` of actions and rewards for previous rounds.
        
    Arguments:
     - `strategy::Type{<:Strategy}`: Strategy name (as DataType);
     - `reward::AbstractArray{Float64}`: Multimentional Array where the first index is the strategy player's action and the remaining indexes are their rivals;
     - `history::Union{NamedTuple,  Missing}`: (If not first round) History of strategy player's actions (`my_action`) and rivals' actions (`their_action`), and realized rewards for previous rounds 
     (`my_reward::Array{Float64,1}`, `their_reward::Array{Float64,2}` - one column per rival);
     - `rounds_left::Union{Int,  Missing}`: (If game discloses this information) Number of rounds left. 
    """
    function _run_strategy(strategy::Type{<:Strategy}, reward::AbstractArray{Float64}, 
        history::Union{NamedTuple{(:my_action, :their_action, :my_reward, :their_reward), Tuple{Vector{Int64}, Matrix{Int64}, Vector{Float64}, Matrix{Float64}}}, Missing},
        rounds_left::Union{Int,  Missing}
    ) 
        @error "No Logic defined for this strategy"
    end

    """
        Game
    
    Basic `num_players` game played `num_rounds` rounds where each player knows the `reward` of each round. If `show_rounds_left` is set, game will disclose how many rounds are left each round.
    """
    struct Game
        rewards::Function # rewards(round) -> Array{Float64, num_players}
        num_rounds::Int
        num_players::Int
        show_rounds_left::Bool
    end

    """
        Game(; rewards, num_rounds, num_players=length(size(rewards(1))), show_rounds_left=true)
    
    Constructs a game of type `Game`.
    Warning: Developers are not sure the infrastructure will work if the following assumption does not hold:
     - Indexes are symmetric (action `i` of player `s` is the same as action `i` of player `k` ∀i,s,k).
    Arguments:
     - `rewards::Function`: Function that returns the reward of each round (`rewards(round) -> Array{Float64, num_players}`);
     - `num_rounds::Int`: Number of rounds in the game;
     - `num_players::Int` Number of players in the game;
     - `show_rounds_left::Bool`: If set, game will disclose how many rounds are left each round.
    """
    function Game(; rewards, num_rounds, num_players=length(size(rewards(1))), show_rounds_left=true)
        @assert num_players > 1
        for iter in 1:num_rounds
            reward = rewards(iter)
            @assert num_players == length(size(reward))
        end

        return Game(rewards, num_rounds, num_players, show_rounds_left)
    end

    """
        find_greedy_action(reward)

    Returns the action with best expected reward.
    """
    function find_greedy_action(reward)
        num_players = length(size(reward))
        return findmax(sum(reward, dims=2:num_players)[:, ones(Int, num_players-1)...])[2]
    end

    """
        find_cooperative_action(reward)

    Returns the action with best expected reward if all players act in the same way. 
    Assumes indexes are symmetric (action `i` of player `s` is the same as action `i` of player `k` ∀i,s,k).
    """
    function find_cooperative_action(reward)
        num_players = length(size(reward))
        return findmax(x -> reward[fill(x, num_players)...], collect(1:num_players))[2]
    end

    """
    play_game(game::Game, strategies::Vector{Type{<:Strategy}})

    Simulates a game for of `N` strategies competing against each other. Where `N` is the appropriate number of players for the game.
    """
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