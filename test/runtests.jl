using SquidGame
using Test

@testset "SquidGame.jl" begin
    @test allunique(SquidGame.AVAILABLE_GAMES)
    @test allunique(SquidGame.AVAILABLE_STRATEGIES)
    @testset "Game: $game_name" for game_name in SquidGame.AVAILABLE_GAMES
        @testset "Number of rounds: $num_rounds" for num_rounds in [1; 10]
            game = game_name(num_rounds)
            @testset "Batle: $strategy_1 vs $strategy_2" for (strategy_1, strategy_2) in collect(Iterators.product(SquidGame.AVAILABLE_STRATEGIES, SquidGame.AVAILABLE_STRATEGIES))
                strategies = Vector{Type{<:Strategy}}()
                push!(strategies, strategy_1)
                push!(strategies, strategy_2)
                realized_reward_history, strategies_action_history = play_game(game, strategies)
                @test typeof(realized_reward_history) === Matrix{Float64}
                @test typeof(strategies_action_history) === Matrix{Int64}
            end
        end
    end
end
