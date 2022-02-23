# Prisoners Dilema
export prisoner

function prisoner(num_rounds)
    return Game(; rewards=(iter) -> [[5. 0]; [10 2]], num_rounds)
end

# Random reward game
export randgame
function randgame(num_rounds; num_players=3, num_actions=3)
    return Game(; rewards=(iter) -> rand(fill(num_actions, num_players)...), num_rounds)
end


push!(AVAILABLE_GAMES, prisoner)
push!(AVAILABLE_GAMES, randgame)
