function BuyMenu:__init()
    self.active = false

    self.window = Window.Create()
    self.window:SetSizeRel( Vector2( 0.3, 0.5 ) )
    self.window:SetPositionRel( Vector2( 0.75, 0.5 ) - self.window:GetSizeRel()/2 )
    self.window:SetVisible( self.active )
    self.window:SetTitle( "Buy Menu" )
    self.window:Subscribe( "WindowClosed", self, self.Close )

    self.tab_control = TabControl.Create( self.window )
    self.tab_control:SetDock( GwenPosition.Fill )

    local base1 = BaseWindow.Create( self.window )
    base1:SetDock( GwenPosition.Bottom )
    base1:SetSize( Vector2( self.window:GetSize().x, 32 ) )

    local background = Rectangle.Create( base1 )
    background:SetSizeRel( Vector2( 0.5, 1.0 ) )
    background:SetDock( GwenPosition.Fill )
    background:SetColor( Color( 0, 0, 0, 100 ) )

    self.money_text = Label.Create( background )
    self.money_text:SetDock( GwenPosition.Fill )
    self.money_text:SetAlignment( GwenPosition.Center )
    self.money_text:SetTextColor( Color( 255, 255, 255 ) )

    self:UpdateMoneyString()

    self.buy_button = Button.Create( base1 )
    self.buy_button:SetSize( Vector2( self.window:GetSize().x/4, 32 ) )
    self.buy_button:SetText( "Buy" )
    self.buy_button:SetDock( GwenPosition.Right )
    self.buy_button:Subscribe( "Press", self, self.Buy )

    self.categories = {}

    self.tone1 = Color( 255, 255, 255 )
    self.tone2 = Color( 255, 255, 255 )

    self:CreateItems()
    self:LoadCategories()

    self.sort_dir = false
    self.last_column = -1

    Events:Subscribe( "Render", self, self.Render )
    Events:Subscribe( "KeyUp", self, self.KeyUp )
    Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
    Events:Subscribe( "LocalPlayerMoneyChange", self, self.LocalPlayerMoneyChange )
    Events:Subscribe( "ModuleLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
end

function BuyMenu:CreateCategory( category_name )
    local t = {}
    t.window = BaseWindow.Create( self.window )
    t.window:SetDock( GwenPosition.Fill )
    t.button = self.tab_control:AddPage( category_name, t.window )

    t.tab_control = TabControl.Create( t.window )
    t.tab_control:SetDock( GwenPosition.Fill )

    t.categories = {}

    self.categories[category_name] = t

    return t
end

function BuyMenu:SortFunction( column, a, b )
    if column ~= -1 then
        self.last_column = column
    elseif column == -1 and self.last_column ~= -1 then
        column = self.last_column
    else
        column = 0
    end

    local a_value = a:GetCellText(column)
    local b_value = b:GetCellText(column)

    if column == 1 then
        local a_num = tonumber(a_value)
        local b_num = tonumber(b_value)

        if a_num ~= nil and b_num ~= nil then
            a_value = a_num
            b_value = b_num
        end
    end

    if self.sort_dir then
        return a_value > b_value
    else
        return a_value < b_value
    end
end

function BuyMenu:CreateSubCategory( category, subcategory_name )
    local t = {}
    t.window = BaseWindow.Create( self.window )
    t.window:SetDock( GwenPosition.Fill )
    t.button = category.tab_control:AddPage( subcategory_name, t.window )

    t.listbox = SortedList.Create( t.window )
    t.listbox:SetDock( GwenPosition.Fill )
    t.listbox:AddColumn( "Item" )
    t.listbox:AddColumn( "Price", 128 )
    t.listbox:SetSort( self, self.SortFunction )

    t.listbox:Subscribe( "SortPress",
        function(button)
            self.sort_dir = not self.sort_dir
        end)

    category.categories[subcategory_name] = t

    return t
end

function BuyMenu:LoadCategories()
    for category_id, category in ipairs(self.items) do
        local category_table = self:CreateCategory(self.id_types[category_id])

        for _, subcategory_name in ipairs(category[1]) do
            local subcategory = category[subcategory_name]

            local subcategory_table = 
                self:CreateSubCategory( category_table, subcategory_name )

            local item_id = 0

            for _, entry in pairs(subcategory) do
                item_id = item_id + 1
                local row = subcategory_table.listbox:AddItem( entry:GetName() )
                row:SetDataNumber( "id", item_id )

                row:SetCellText( 1, tostring(entry:GetPrice()) )

                entry:SetListboxItem( row )
            end
        end

        -- Slightly hacky
        if category_id == self.types.Vehicle then
            local window = BaseWindow.Create( self.window )
            window:SetDock( GwenPosition.Fill )
            category_table.tab_control:AddPage( "Colours", window )

            local tab_control = TabControl.Create( window )
            tab_control:SetDock( GwenPosition.Fill )

            local tone1 = HSVColorPicker.Create()
            tab_control:AddPage( "Tone 1", tone1 )
            tone1:SetDock( GwenPosition.Fill )
            tone1:Subscribe( "ColorChanged", function()
                self.tone1 = tone1:GetColor()
            end )
            tone1:SetColor( Color( 255, 255, 255 ) )
            self.tone1 = tone1:GetColor()
            
            local tone2 = HSVColorPicker.Create()
            tab_control:AddPage( "Tone 2", tone2 )
            tone2:SetDock( GwenPosition.Fill )
            tone2:Subscribe( "ColorChanged", function()
                self.tone2 = tone2:GetColor() 
            end )
            tone2:SetColor( Color( 255, 255, 255 ) )
            self.tone2 = tone2:GetColor()
            
			tone1:SetColor(LocalPlayer:GetColor())
			tone2:SetColor(LocalPlayer:GetColor())
            
            local setColorBtn = Button.Create(window)
            setColorBtn:SetText("Set Color")
            setColorBtn:SetDock( GwenPosition.Bottom )
            setColorBtn:Subscribe( "Down", function()
                Network:Send( "ColorChanged", { tone1 = self.tone1, tone2 = self.tone2 } )
            end )
        end
    end
end

function BuyMenu:UpdateMoneyString( money )
    if money == nil then
        money = LocalPlayer:GetMoney()
    end

    self.money_text:SetText( 
        string.format( "Money: $%i",
                        money ) )
end

function BuyMenu:LocalPlayerMoneyChange( args )
    self:UpdateMoneyString( args.new_money )
end

function BuyMenu:GetActive()
    return self.active
end

function BuyMenu:SetActive( active )
    if self.active ~= active then
        if active == true and LocalPlayer:GetWorld() ~= DefaultWorld then
            Chat:Print( "You are not in the main world!", Color( 255, 0, 0 ) )
            return
        end

        self.active = active
        Mouse:SetVisible( self.active )
    end
end

function BuyMenu:Render()
    local is_visible = self.active and (Game:GetState() == GUIState.Game)

    if self.window:GetVisible() ~= is_visible then
        self.window:SetVisible( is_visible )
    end

    if self.active then
        Mouse:SetVisible( true )
    end
end

function BuyMenu:KeyUp( args )
    if args.key == string.byte('B') then
        self:SetActive( not self:GetActive() )
    end
end

function BuyMenu:LocalPlayerInput( args )
    if self.active and Game:GetState() == GUIState.Game then
        return false
    end
end

function BuyMenu:ModulesLoad()
    Events:Fire( "HelpAddItem",
        {
            name = "Buy Menu",
            text = 
                "To use the buy menu, press the B button. From there, " ..
                "simply select an item and press buy to purchase it. " ..
                "To close the menu, hit the close button.\n\n" ..
                "Any vehicles you buy through the buy menu will be removed " ..
                "on disconnection from the server. However, any models you buy " ..
                "will automatically be re-applied on server rejoin."
        } )
end

function BuyMenu:ModuleUnload()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Buy Menu"
        } )
end

function BuyMenu:Buy( args )
    local category_name = self.tab_control:GetCurrentTab():GetText()
    local category = self.categories[category_name]

    local subcategory_name = category.tab_control:GetCurrentTab():GetText() 
    local subcategory = category.categories[subcategory_name]

    if subcategory == nil then return end

    local listbox = subcategory.listbox

    local first_selected_item = listbox:GetSelectedRow()

    if first_selected_item ~= nil then
        local index = first_selected_item:GetDataNumber( "id" )
        Network:Send( "PlayerFired", { self.types[category_name], subcategory_name, index, self.tone1, self.tone2 } )
        self:SetActive( false )
    end
end

function BuyMenu:Close( args )
    self:SetActive( false )
end

local buy_menu = BuyMenu()
