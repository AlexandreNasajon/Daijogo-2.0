local Player = require("Player")
local Functions = {}


-----------PRINT CARD-------------------------------------------------------------------------------------------------------------------------------------------
Functions.printcard = function(card)
    print("Name: "..card.name)
    print("Cost: "..card.cost)
    print("Type: "..card.tipo)
    if card.power then
        print("Power: "..card.power)
    end
    print("Description: "..card.description)
end

--------shuffle---------------------------------------------------------------------------------------------------------------------------------------------
Functions.shuffle = function(a)
	local c = #a
	for i = 1, c do
		local ndx0 = math.random( 1, c )
		a[ ndx0 ], a[ i ] = a[ i ], a[ ndx0 ]
	end
	return a
end

------------COPIAR---------------------------------------------------------------------------------------------------------------------------------------------
Functions.copiar = function(card,b)
    for k,v in pairs(card) do
        b[k] = v
    end
    return b
end

----------FIND--------------------------------------------------------------------------------------------------------------------------------------------------
Functions.find = function(a,n)
    for k,v in pairs(a) do
        if v == n then
        return k
        end
    end
end

------------DRAW----------------------------------------------------------------------------------------------------------------------------------------------------
Functions.draw = function(p1,p2)
    p1.hand[#p1.hand+1] = p1.deck[#p1.deck]
    p1.deck[#p1.deck] = nil
    print(p1.name.." drew one card.")
end

----------GET COINS-------------------------------------------------------------------------------------------------------------------------------------------------
Functions.getcoins = function(p1,n)
    p1.coins = p1.coins+n
    if n > 1 then
        print(p1.name.." received"..n.." coins.")
    elseif n == 1 then
        print(p1.name.." received 1 coin.")
    end
end

---------GET ENERGY------------------------------------------------------------------------------------------------------------------------------------------------
Functions.getenergy = function(card)
    card.energy = card.energy +1
end

-----------DAMAGE----------------------------------------------------------------------------------------------------------------------------------------------------------------------
Functions.damage = function(p1,n)
    p1.life = p1.life - n
end
-----------GAIN LIFE---------------------------------------------------------------------------------------------------------------------------------------------------------------------
Functions.gainlife = function(p1,n)
    p1.life = p1.life + n
end
--------DISCARD--------------------------------------------------------------------------------------------------------------------------------------------------
Functions.discard = function(p1,p2)
    local h = false
    while h == false do
        print("Discard a card:")
        Functions.printzone(p1.hand)
        local opcao = tonumber(io.read())
        if opcao ~= nil and opcao <= #p1.hand and opcao > 0 then
            p1.graveyard[#p1.graveyard+1] = p1.hand[opcao]
            while opcao <= #p1.hand do
                p1.hand[opcao] = p1.hand[opcao+1]
                opcao = opcao+1
            end
            h = true
        else
            print("YOU MUST DISCARD A CARD!")
        end
    end
    if p1.graveyard[#p1.graveyard].tipo == "Unit" then
        if p1.graveyard[#p1.graveyard].effect.ifdiscarded then
            p1.graveyard[#p1.graveyard].effect.ifdiscarded(p1.graveyard[#p1.graveyard],p1,p2)
        end
    end
end

-----------DESTROY------------------------------------------------------------------------------------------------------------------------------------------------
Functions.destroy = function(card,p1,p2) -- p1 is controller/p2 is opponent

    if card.effect.ifwoulddie then
        card.effect.ifwoulddie(card,p1,p2)
    else

    p1.graveyard[#p1.graveyard+1] = card

        if card.tipo == "Unit" then
            local j = Functions.find(p1.field.vanguard,card)
            if j =~ nil then
                p1.field.vanguard[j] = nil
            elseif j == nil then
                local j = Functions.find(p1.field.rearguard,card)
                p1.field.rearguard[j] = nil
            end

        elseif card.tipo == "Ally" or card.tipo == "Building" then
            local j = Functions.find(p1.castle,card)
            p1.castle[j] = nil
--[[        while j <= #p1.castle do
                 p1.castle[j] = p1.castle[j+1]
                 j = j+1
            end
--]]
        end
        print(card.name.." was destroyed.")
        if card.effect then
            if card.effect.ifdies then
                card.effect.ifdies(card,p1,p2)
            end
        end
    end
end

-----------COMBAT---------------------------------------------------------
Functions.combat = function(atacante,defensor,p1,p2) -- p1 is controller of atacante/p2 is controller of defensor

    if atacante.power > defensor.power then
        Functions.destroy(defensor,p2,p1)
    elseif atacante.power == defensor.power then
        Functions.destroy(defensor,p2,p1)
        Functions.destroy(atacante,p1,p2)
    elseif atacante.power < defensor.power then
        Functions.destroy(atacante,p1,p2)
    end
end

------------ERASE---------------------------------------------------------------------------------------------------------------------------------------------------
Functions.erase = function(card,p1,p2) -- p1 is controller/p2 is opponent
    p1.erased[#p1.erased+1] = card

        if card.tipo == "Unit" then
            local j = Functions.find(p1.field.vanguard,card)
            if j =~ nil then
                p1.field.vanguard[j] = nil
            elseif j == nil then
                local j = Functions.find(p1.field.rearguard,card)
                p1.field.rearguard[j] = nil
            end

        elseif card.tipo == "Ally" or card.tipo == "Building" then
            local j = Functions.find(p1.castle,card)
            p1.castle[j] = nil
--[[        while j <= #p1.castle do
                 p1.castle[j] = p1.castle[j+1]
                 j = j+1
            end
--]]
        end

    print(card.name.." was erased.")
end


-----------SEND TO CASTLE-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
Functions.sendtocastle = function(card,p1,p2)
    print("Send "..card.name.." to which castle zone?")
    print("0 - None")
    print("1 - "..p1.castle.left,"2 - "..p1.castle.right)
    h = false
    while h == false do
        decisao = tonumber(io.read())
        if decisao == 0 then
            h = true
        elseif decisao == 1 and p1.castle.left == nil then -- if there are no cards in that zone
            p1.castle.left = card
            if card.tipo == "Ally" then
                print(card.name.." was summoned to your castle.")
            elseif card.tipo == "Building" then
                print(card.name.." was built.")
            end
            h = true
        elseif decisao == 1 and p1.castle.left =~ nil then
            print("THAT ZONE IS ALREADY BEING USED!")
        elseif decisao == 2 and p1.castle.right == nil then
            p1.castle.right = card
            if card.tipo == "Ally" then
                print(card.name.." was summoned to your castle.")
            elseif card.tipo == "Building" then
                print(card.name.." was built.")
            end
            h = true
        elseif decisao == 2 and p1.castle.right =~ nil then
            print("THAT ZONE IS ALREADY BEING USED!")
        else
            print("SELECT A VALID OPTION!")
        end
    end
end

-----------DEPLOY TO VANGUARD------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Functions.deploy_van = function(card,p1,p2)
    print("Send "..card.name.." to which vanguard zone?")
    print("0 - None")
    print("1 - "..p1.vanguard.left,"2 - "..p1.vanguard.middle,"3 - "..p1.vanguard.right)
    h = false
    while h == false do
        decisao = tonumber(io.read())
        if decisao == 0 then
            h = true
        elseif decisao == 1 and p1.vanguard.left == nil then -- if there are no cards in that zone
            p1.vanguard.left = card
            print(card.name.." was deployed to your vanguard.")
            h = true
        elseif decisao == 1 and p1.vanguard.left =~ nil then
            print("THAT ZONE IS ALREADY BEING USED!")
        elseif decisao == 2 and p1.vanguard.middle == nil then
            p1.vanguard.left = card
            print(card.name.." was deployed to your vanguard.")
            h = true
        elseif decisao == 2 and p1.vanguard.middle =~ nil then
            print("THAT ZONE IS ALREADY BEING USED!")
        elseif decisao == 3 and p1.vanguard.right == nil then
            p1.vanguard.right = card
            print(card.name.." was deployed to your vanguard.")
            h = true
        elseif decisao == 3 and p1.vanguard.right =~ nil then
            print("THAT ZONE IS ALREADY BEING USED!")
        else
            print("SELECT A VALID OPTION!")
        end
    end
end

-----------DEPLOY TO REARGUARD------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Functions.deploy_rear = function(card,p1,p2)
    print("Send "..card.name.." to which rearguard zone?")
    print("0 - None")
    print("1 - "..p1.rearguard.left,"2 - "..p1.rearguard.middle,"3 - "..p1.rearguard.right)
    h = false
    while h == false do
        decisao = tonumber(io.read())
        if decisao == 0 then
            h = true
        elseif decisao == 1 and p1.rearguard.left == nil then -- if there are no cards in that zone
            p1.rearguard.left = card
            print(card.name.." was deployed to your rearguard.")
            h = true
        elseif decisao == 1 and p1.rearguard.left =~ nil then
            print("THAT ZONE IS ALREADY BEING USED!")
        elseif decisao == 2 and p1.rearguard.middle == nil then
            p1.rearguard.left = card
            print(card.name.." was deployed to your rearguard.")
            h = true
        elseif decisao == 2 and p1.rearguard.middle =~ nil then
            print("THAT ZONE IS ALREADY BEING USED!")
        elseif decisao == 3 and p1.rearguard.right == nil then
            p1.rearguard.right = card
            print(card.name.." was deployed to your rearguard.")
            h = true
        elseif decisao == 3 and p1.rearguard.right =~ nil then
            print("THAT ZONE IS ALREADY BEING USED!")
        else
            print("SELECT A VALID OPTION!")
        end
    end
end

----------PLAY------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Functions.play = function(card,p1,p2)

    if card.tipo == "Unit" then
        h = false
        while h == false do
            print("Deploy "..card.name.." to the vanguard or the rearguard?")
            print("0 - None")
            print("1 - Vanguard")
            print("2 - Rearguard")
            decisao = tonumber(io.read())
            if decisao == 0 then
                h = true
            elseif decisao == 1 then
                Functions.deploy_van(card,p1,p2)
                h = true
            elseif decisao == 2 then
                Functions.deploy_rear(card,p1,p2)
                h = true
            end
        end
    elseif card.tipo == "Support" then
        card.effect(card,p1,p2)
        p1.graveyard[#p1.graveyard+1] = card
        p1.lastsupport = card
    elseif card.tipo == "Ally" or card.tipo == "Building" then
        Functions.sendtocastle(card,p1,p2)
    end
end


-----------COLLECT PHASE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Functions.collect = function(p1,p2)
print(p1.name.."'S COLLECT PHASE")
    collecteffects = {Functions.draw(p1,p2),Functions.getcoins(p1,1)}
    -------------------Checks if there are any effects in the catle-----------------------
    if p1.castle.left =~ nil then
        local cardcollect = {card = p1.castle.left,collect = p1.castle.left.effect.atcollect}
        eoteffects[#eoteffects+1] = cardeot
    elseif p1.castle.right =~ nil then
        local cardcollect = {card = p1.castle.right,collect = p1.castle.right.effect.atcollect}
        collecteffects[#collecteffects+1] = cardcollect
    end
------------------Checks if there are any rearguard effects-------------------------
    if p1.rearguard.left =~ nil then
        local cardcollect = {card = p1.rearguard.left,collect = p1.rearguard.left.effect.atcollect}
        collecteffects[#collecteffects+1] = cardcollect
    elseif p1.rearguard.middle =~ nil then
        local cardcollect = {card = p1.rearguard.middle,eot = p1.rearguard.middle.effect.atcollect}
        collecteffects[#collecteffects+1] = cardcollect
    elseif p1.castle.right =~ nil then
        local cardcollect = {card = p1.rearguard.right,collect = p1.rearguard.right.effect.atcollect}
        collecteffects[#collecteffects+1] = cardcollect
    end

------------------Checks if there are any vanguard effects-------------------------
    if p1.vanguard.left =~ nil then
        local cardcollect = {card = p1.vanguard.left,collect = p1.vanguard.left.effect.atcollect}
        collecteffects[#collecteffects+1] = cardcollect
    elseif p1.vanguard.middle =~ nil then
        local cardcollect = {card = p1.vanguard.middle,collect = p1.vanguard.middle.effect.atcollect}
        collecteffects[#collecteffects+1] = cardcollect
    elseif p1.castle.right =~ nil then
        local cardcollect = {card = p1.vanguard.right,collect = p1.vanguard.right.effect.atcollect}
        collecteffects[#collecteffects+1] = cardcollect
    end

    --[[for guard = rearguard,vanguard do
        for zone = left,middle,right do
            if p1.guard.zone =~ nil then
                local cardcollect = {card = p1.guard.zone,collect = p1.guard.zone.effect.atcollect}
                collecteffects[#collecteffects+1] = cardcollect
            end
        end
    end
--]]
------------------Checks if there are any unit effects in the graveyard--------------
    if #p1.graveyard > 0 then
        local i = 1
        while i <= #p1.graveyard do
            if p1.graveyard[i].tipo == "Unit" then
                if p1.graveyard[i].effect.ateotgrave then
                    local cardcollect = {card = p1.graveyard[i],collect = p1.graveyard[i].effect.atcollectgrave}
                    collecteffects[#collecteffects+1] = cardcollect
                end
            end
            i = i+1
        end
    end
-----------------Activates the effects----------------------------
    if #collecteffects > 0 then
        local i = 1
        while i <= #collecteffects do
            local card = collecteffects[i].card -- finds out to which card belongs the effect
            local collect = collecteffects[i].collect -- the effect
            collect(card,p1,p2) -- calls the effect of the card
            i = i+1
        end
    end
end

-----------MAIN PHASE----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Functions.mainphase = function(p1,p2)
print(p1.name.."'S MAIN PHASE")

        print("It's player "..Player[t].name.." turn!")
        print(Player[y].name)
        print("Life: "..Player[y].life)
        print("ENEMY CASTLE")
        print(p2.castle.left.name,Player[y].name,p2.castle.right.name)
        print("ENEMY REARGUARD")
        print(p2.rearguard.left.name,p2.rearguard.middle.name,p2.rearguard.right.name)
        print("ENEMY VANGUARD")
        print(p2.vanguard.left.name,p2.vanguard.middle.name,p2.vanguard.right.name)
        print("--------------------------------------------------------------------------------")
        print("Life: "..Player[t].life,"Gold: "..Player[t].gold)
        print("1 - YOUR VANGUARD")
        print(p1.vanguard.left.name,p1.vanguard.middle.name,p1.vanguard.right.name)
        print("2 - YOUR REARGUARD")
        print(p1.rearguard.left.name,p1.rearguard.middle.name,p1.rearguard.right.name)
        print("3 - YOUR CASTLE")
        print(p1.castle.left.name,Player[t].name,p1.castle.right.name)
        print("4 - YOUR HAND")
        print("#","Name           ","Cost","Type") if p1.hand[i].power then print("Power") end
        print(p1.hand[i].name,p1.hand[i].cost,p1.hand[i].tipo) if p1.hand[i].power then print(p1.hand[i].power) end
        print("5 - Graveyard")
        print("6 - Special Deck")
        print("7 - End Turn")

end


-----------End TURN------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Functions.endturn = function(p1,p2)
print(p1.name.."'S END PHASE")
    eoteffects = {}
-------------------Checks if there are any effects in the catle-----------------------
    if p1.castle.left =~ nil then
        local cardeot = {card = p1.castle.left,eot = p1.castle.left.effect.ateot}
        eoteffects[#eoteffects+1] = cardeot
    elseif p1.castle.right =~ nil then
        local cardeot = {card = p1.castle.right,eot = p1.castle.right.effect.ateot}
        eoteffects[#eoteffects+1] = cardeot
    end
------------------Checks if there are any rearguard effects-------------------------
    if p1.rearguard.left =~ nil then
        local cardeot = {card = p1.rearguard.left,eot = p1.rearguard.left.effect.ateot}
        eoteffects[#eoteffects+1] = cardeot
    elseif p1.rearguard.middle =~ nil then
        local cardeot = {card = p1.rearguard.middle,eot = p1.rearguard.middle.effect.ateot}
        eoteffects[#eoteffects+1] = cardeot
    elseif p1.castle.right =~ nil then
        local cardeot = {card = p1.rearguard.right,eot = p1.rearguard.right.effect.ateot}
        eoteffects[#eoteffects+1] = cardeot
    end

------------------Checks if there are any vanguard effects-------------------------
    if p1.vanguard.left =~ nil then
        local cardeot = {card = p1.vanguard.left,eot = p1.vanguard.left.effect.ateot}
        eoteffects[#eoteffects+1] = cardeot
    elseif p1.vanguard.middle =~ nil then
        local cardeot = {card = p1.vanguard.middle,eot = p1.vanguard.middle.effect.ateot}
        eoteffects[#eoteffects+1] = cardeot
    elseif p1.castle.right =~ nil then
        local cardeot = {card = p1.vanguard.right,eot = p1.vanguard.right.effect.ateot}
        eoteffects[#eoteffects+1] = cardeot
    end

------------------Checks if there are any unit effects in the graveyard--------------
    if #p1.graveyard > 0 then
        local i = 1
        while i <= #p1.graveyard do
            if p1.graveyard[i].tipo == "Unit" then
                if p1.graveyard[i].effect.ateotgrave then
                    local cardeot = {card = p1.graveyard[i],eot = p1.graveyard[i].effect.ateotgrave}
                    eoteffects[#eoteffects+1] = cardeot
                end
            end
            i = i+1
        end
    end
-----------------Activates the effects----------------------------
    if #eoteffects > 0 then
        local i = 1
        while i <= #eoteffects do
            local card = eoteffects[i].card
            local eot = eoteffects[i].eot
            eot(card,p1,p2)
            i = i+1
        end
    end

    print(p1.name.."'s turn ends.")
end







return Functions
