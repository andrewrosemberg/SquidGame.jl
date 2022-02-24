@userplot ScoreBoard
@recipe function f(S::ScoreBoard)
    scores, strategies = S.args

    # reverse the scores so the rounds go are descending
    scores = reverse(scores, dims = 1)
    rounds = 1:size(scores, 1)

    xguide --> "Strategy"
    yguide --> "round"
    seriestype --> :heatmap
    seriescolor --> :RdYlGn_10

    ystrings = reverse(string.(rounds))

    xlabels = (1:size(scores, 2), strategies)
    ylabels = (rounds, ystrings)

    xticks := xlabels
    yticks := (1:length(rounds), ystrings)

    #=
    round_winner_idxs = getproperty.(findmax(scores, dims = 2)[2], :I)
    annotations --> (
        last.(round_winner_idxs),
        first.(round_winner_idxs),
        ( "winner", :black, :center)
    )
    =#

    return(xlabels, ylabels, scores)

end
