# Prisoners Dilema
export prisoner

prisoner(num_rounds) = Game(; rewards=(iter) -> [[5. 0]; [10 2]], num_rounds)

push!(AVAILABLE_GAMES, prisoner)