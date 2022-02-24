```@meta
CurrentModule = SquidGame
```

```@raw html
<div style="width:100%; height:150px;border-width:4px;border-style:solid;padding-top:25px;
        border-color:#000;border-radius:10px;text-align:center;background-color:#99DDFF;
        color:#000">
    <h3 style="color: black;">Star us on GitHub!</h3>
    <a class="github-button" href="https://github.com/andrewrosemberg/SquidGame.jl" data-icon="octicon-star" data-size="large" data-show-count="true" aria-label="Star andrewrosemberg/SquidGame.jl on GitHub" style="margin:auto">Star</a>
    <script async defer src="https://buttons.github.io/buttons.js"></script>
</div>
```

# SquidGame

Documentation for [SquidGame](https://github.com/andrewrosemberg/SquidGame.jl).

Strategy simulation for simple games.

## Instalation

```julia
] add SquidGame
```

## Overview

Using function `play_game`, simulates a game for of `N` strategies competing against each other (where `N` is the appropriate number of players for the game).

Implementable games are "deterministic" games where each player knows the possible rewards for each round at decision time, with the only uncertainty being the action of other players.

Rewards are defined as a multi-dimensional array where entries your action is the first index and rivals are the remaining indexes. For example, a 2 player game:

|               | Rival Action 1| Rival Action 2|
| ------------- | ------------- | ------------- |
| Your Action 1 |      5.0      |      0.0      |
| Your Action 2 |      10.0     |      2.0      |

In this case:
 - If you acted with action `1` and your rival also chose action `1`, you would both earn `5` points;
 - If you acted with action `1` and your rival chose action `2`, you would earn `0` and they would earn `10`. 
