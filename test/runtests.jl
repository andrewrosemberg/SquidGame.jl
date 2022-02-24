using SquidGame
using Test

@testset "SquidGame.jl" begin
    @test allunique(SquidGame.AVAILABLE_GAMES)
    @test allunique(SquidGame.AVAILABLE_STRATEGIES)

    # Plays all AVAILABLE_STRATEGIES against each other in all AVAILABLE_GAMES.
    @testset "Game: $game_name" for game_name in SquidGame.AVAILABLE_GAMES
        @testset "Number of rounds: $num_rounds" for num_rounds in [1; 10]
            game = game_name(num_rounds)
            num_players = length(size(game.rewards(1)))
            @testset "Battle: $strategies_pool" for strategies_pool in collect(Iterators.product(fill(SquidGame.AVAILABLE_STRATEGIES, num_players)...))
                strategies = Vector{Type{<:Strategy}}()
                for strategy in strategies_pool
                    push!(strategies, strategy)
                end
                realized_reward_history, strategies_action_history = play_game(game, strategies)
                @test typeof(realized_reward_history) === Matrix{Float64}
                @test typeof(strategies_action_history) === Matrix{Int64}
            end
        end
    end
end
