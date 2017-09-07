local Player = {}


Player[1] = {
    life = 100,
    coins = 0,
    deck = {},
    special = {},
    hand = {},
    field = {vanguard = {left,middle,right},rearguard = {left,middle,right}},
    graveyard = {},
    erased = {},
    lastsupport = {},
    castle = {left,right},
    stack = {}
    }

Player[2] = {
    life = 100,
    coins = 0,
    deck = {},
    special = {},
    hand = {},
    field = {vanguard = {left,middle,right},rearguard = {left,middle,right}},
    graveyard = {},
    erased = {},
    lastsupport = {},
    castle = {left,right},
    stack = {}
    }

return Player
