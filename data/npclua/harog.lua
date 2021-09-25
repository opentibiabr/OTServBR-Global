local internalNpcName = "Harog"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 160,
	lookHead = 37,
	lookBody = 16,
	lookLegs = 54,
	lookFeet = 114
}

npcConfig.flags = {
	floorchange = false
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

local function getTable(player)
	local itemsList = {
		{name="metal fitting", id=9115, buy=500},
		{name="nail", id=953, sell=10},
		{name="flask of rust remover", id=9016, buy=50}
	}

	local rustremover = {
		{name="flask of rust remover", id=9016, buy=50},
	}

	if player:getStorageValue(Storage.HiddenCityOfBeregar.JusticeForAll) == 6 then
		for i = 1, #rustremover do
			itemsList[#itemsList] = rustremover[i]
		end
	end

	return itemsList
end

local function setNewTradeTable(table)
	local items, item = {}
	for i = 1, #table do
		item = table[i]
		items[item.id] = {itemId = item.id, buyPrice = item.buy, sellPrice = item.sell, subType = 0, realName = item.name}
	end
	return items
end

local function onBuy(creature, item, subType, amount, ignoreCap, inBackpacks)
	local player = Player(creature)
	local items = setNewTradeTable(getTable(player))
	if not ignoreCap and player:getFreeCapacity() < ItemType(items[item].itemId):getWeight(amount) then
		return player:sendTextMessage(MESSAGE_FAILURE, 'You don\'t have enough cap.')
	end
	if not player:removeMoneyBank(items[item].buyPrice * amount) then
		selfSay("You don't have enough money.", npc, creature)
	else
		player:addItem(items[item].itemId, amount)
		return player:sendTextMessage(MESSAGE_TRADE, 'Bought '..amount..'x '..items[item].realName..' for '..items[item].buyPrice * amount..' gold coins.')
	end
	return true
end

local function onSell(creature, item, subType, amount, ignoreCap, inBackpacks)
	local player = Player(creature)
	local items = setNewTradeTable(getTable(player))
	if items[item].sellPrice and player:removeItem(items[item].itemId, amount) then
		player:addMoney(items[item].sellPrice * amount)
		return player:sendTextMessage(MESSAGE_TRADE, 'Sold '..amount..'x '..items[item].realName..' for '..items[item].sellPrice * amount..' gold coins.')
	else
		selfSay("You don't have item to sell.", npc, creature)
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local playerId = creature:getId()
	if msgcontains(message, "trade") then
		local player = Player(creature)
		local items = setNewTradeTable(getTable(player))
		openShopWindow(creature, getTable(player), onBuy, onSell)
		npcHandler:say("Keep in mind you won't find better offers here. Just browse through my wares.", npc, creature)
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, 'Hello.')
npcHandler:setMessage(MESSAGE_FAREWELL, 'It was a pleasure to help you, |PLAYERNAME|.')
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new())

-- npcType registering the npcConfig table
npcType:register(npcConfig)
