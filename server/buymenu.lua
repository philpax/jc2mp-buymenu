-- Player extension methods
function Player:SendErrorMessage( str )
    self:SendChatMessage( str, Color( 255, 0, 0 ) )
end

function Player:SendSuccessMessage( str )
    self:SendChatMessage( str, Color( 0, 255, 0 ) )
end

-- Buy Menu
function BuyMenu:__init()
    self.items      = {}
    self.vehicles   = {}
    self.hotspots   = {}

    self.ammo_counts            = {
        [2] = { 12, 60 }, [4] = { 7, 35 }, [5] = { 30, 90 },
        [6] = { 3, 18 }, [11] = { 20, 100 }, [13] = { 6, 36 },
        [14] = { 4, 32 }, [16] = { 3, 12 }, [17] = { 5, 5 },
        [28] = { 26, 130 }
    }

    self:CreateItems()

    Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
    Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )

    Events:Subscribe( "SpawnPoint", self, self.AddHotspot )
    Events:Subscribe( "TeleportPoint", self, self.AddHotspot )

    Network:Subscribe( "PlayerFired", self, self.PlayerFired )    
    Network:Subscribe( "ColorChanged", self, self.ColorChanged )

    SQL:Execute( "create table if not exists buymenu_players (steamid VARCHAR UNIQUE, model_id INTEGER)")
end

-- Utility
function BuyMenu:IsInHotspot( pos )
    for _, v in ipairs(self.hotspots) do
        if (pos - v):LengthSqr() < 625 then -- 25m deadzone
            return true
        end
    end

    return false
end

-- Events
function BuyMenu:ColorChanged( args, sender )
    local veh = sender:GetVehicle()
    if IsValid(veh) then
        veh:SetColors( args.tone1, args.tone2 )
    end
end
function BuyMenu:PlayerJoin( args )
    local qry = SQL:Query( "select model_id from buymenu_players where steamid = (?)" )
    qry:Bind( 1, args.player:GetSteamId().id )
    local result = qry:Execute()

    if #result > 0 then
        args.player:SetModelId( tonumber(result[1].model_id) )
    end
end

function BuyMenu:PlayerQuit( args )
    if IsValid( self.vehicles[ args.player:GetId() ] ) then
        self.vehicles[ args.player:GetId() ]:Remove()
        self.vehicles[ args.player:GetId() ] = nil
    end
end

function BuyMenu:ModuleUnload()
    for k, v in pairs(self.vehicles) do
        if IsValid( v ) then
            v:Remove()
        end
    end
end

function BuyMenu:AddHotspot( pos )
    for _, v in ipairs(self.hotspots) do
        if (pos - v):LengthSqr() < 16 then -- 4m error
            return
        end
    end
    
    table.insert( self.hotspots, pos )
end

function BuyMenu:PlayerFired( args, player )
    local category_id       = args[1]
    local subcategory_name  = args[2]
    local index             = args[3]
    local tone1             = args[4]
    local tone2             = args[5]

    local hotspot_categories = {
        self.types.Vehicle
    }

    if player:GetWorld() ~= DefaultWorld then
        player:SendErrorMessage( "You are not in the main world!" )
        return
    end

    if  self:IsInHotspot( player:GetPosition() ) and 
        table.find( hotspot_categories, category_id ) ~= nil then

        player:SendErrorMessage( 
            "You are in a hotspot! You can't buy that kind of item here." )
        return
    end

    local item = self.items[category_id][subcategory_name][index]

    if item == nil then
        player:SendErrorMessage( "Invalid item!" )
        return
    end

    if player:GetMoney() < item:GetPrice() then
        local str = string.format(
            "You do not have enough money for a %s! "..
            "You need an additional $%i.",
            item:GetName(),
            item:GetPrice() - player:GetMoney() )

        player:SendErrorMessage( str )
        return
    end 

    local success, err    

    if category_id == self.types.Vehicle then
        success, err = self:BuyVehicle( player, item, tone1, tone2 )
    elseif category_id == self.types.Weapon then           
        success, err = self:BuyWeapon( player, item )
    elseif category_id == self.types.Model then
        success, err = self:BuyModel( player, item )
    end

    if success then
        player:SetMoney( player:GetMoney() - item:GetPrice() )

        local str = string.format(
            "You have purchased a %s for $%i! Your balance is now $%i.",
            item:GetName(),
            item:GetPrice(),
            player:GetMoney() )

        player:SendSuccessMessage( str )
    else
        player:SendErrorMessage( err )
    end
end

function BuyMenu:BuyVehicle( player, item, tone1, tone2 )
    if player:GetState() == PlayerState.InVehiclePassenger then
        return false, "You cannot purchase a vehicle while in the passenger seat!"
    end

    if IsValid( self.vehicles[ player:GetId() ] ) then
        self.vehicles[ player:GetId() ]:Remove()
        self.vehicles[ player:GetId() ] = nil
    end

    local args = {}
    args.model_id           = item:GetModelId()
    args.position           = player:GetPosition()
    args.angle              = player:GetAngle()
    args.linear_velocity    = player:GetLinearVelocity() * 1.1
    args.enabled            = true
    args.tone1              = tone1
    args.tone2              = tone2

    local v = Vehicle.Create( args )
    self.vehicles[ player:GetId() ] = v

    v:SetUnoccupiedRespawnTime( nil )
    player:EnterVehicle( v, VehicleSeat.Driver )

    return true, ""
end

function BuyMenu:BuyWeapon( player, item )
    player:GiveWeapon( item:GetSlot(), 
        Weapon( item:GetModelId(), 
            self.ammo_counts[item:GetModelId()][1] or 0,
            (self.ammo_counts[item:GetModelId()][2] or 200) * 6 ) )

    return true, ""
end

function BuyMenu:BuyModel( player, item )
    player:SetModelId( item:GetModelId() )

    local cmd = SQL:Command( 
        "insert or replace into buymenu_players (steamid, model_id) values (?, ?)" )
    cmd:Bind( 1, player:GetSteamId().id )
    cmd:Bind( 2, item:GetModelId() )
    cmd:Execute()

    return true, ""
end

buy_menu = BuyMenu()
