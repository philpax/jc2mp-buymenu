class 'BuyMenu'
class 'BuyMenuEntry'

function BuyMenuEntry:__init( model_id, price, entry_type )
    self.model_id = model_id
    self.price = price
    self.entry_type = entry_type
end

function BuyMenuEntry:GetPrice()
    return self.price
end

function BuyMenuEntry:GetModelId()
    return self.model_id
end

function BuyMenuEntry:GetListboxItem()
    return self.listbox_item
end

function BuyMenuEntry:SetListboxItem( item )
    self.listbox_item = item
end

class 'VehicleBuyMenuEntry' (BuyMenuEntry)

function VehicleBuyMenuEntry:__init( model_id, price )
    BuyMenuEntry.__init( self, model_id, price, 1 )
end

function VehicleBuyMenuEntry:GetName()
    return Vehicle.GetNameByModelId( self.model_id )
end

class 'WeaponBuyMenuEntry' (BuyMenuEntry)

function WeaponBuyMenuEntry:__init( model_id, price, slot, name )
    BuyMenuEntry.__init( self, model_id, price, 2 )
    self.slot = slot
    self.name = name
end

function WeaponBuyMenuEntry:GetSlot()
    return self.slot
end

function WeaponBuyMenuEntry:GetName()
    return self.name
end

class 'ModelBuyMenuEntry' (BuyMenuEntry)

function ModelBuyMenuEntry:__init( model_id, price, name )
    BuyMenuEntry.__init( self, model_id, price, 2 )
    self.name = name
end

function ModelBuyMenuEntry:GetName()
    return self.name
end

function BuyMenu:CreateItems()
    self.types = {
        ["Vehicle"] = 1,
        ["Weapon"] = 2,
        ["Model"] = 3
    }

    self.id_types = {}

    for k, v in pairs(self.types) do
        self.id_types[v] = k
    end
    self.items = {
        [self.types.Vehicle] = {
            { "Land", "Air", "Sea" },
            ["Land"] = {
                VehicleBuyMenuEntry( 2, 1000 ),
                VehicleBuyMenuEntry( 4, 750 ),
                VehicleBuyMenuEntry( 11, 250 ),
                VehicleBuyMenuEntry( 13, 600 ),
                VehicleBuyMenuEntry( 18, 5000 ),
                VehicleBuyMenuEntry( 21, 400 ),
                VehicleBuyMenuEntry( 22, 200 ),
                VehicleBuyMenuEntry( 35, 1500 ),
                VehicleBuyMenuEntry( 43, 400 ),
                VehicleBuyMenuEntry( 46, 800 ),
                VehicleBuyMenuEntry( 54, 1000 ),
                VehicleBuyMenuEntry( 56, 5000 ),
                VehicleBuyMenuEntry( 72, 800 ),
                VehicleBuyMenuEntry( 76, 2000 ),
                VehicleBuyMenuEntry( 77, 2500 ),
                VehicleBuyMenuEntry( 78, 1100 ),
                VehicleBuyMenuEntry( 79, 1300 ),
                VehicleBuyMenuEntry( 87, 700 ),
                VehicleBuyMenuEntry( 89, 450 ),
                VehicleBuyMenuEntry( 91, 1000 ),
                -- DLC
                --VehicleBuyMenuEntry( 20, 8000 ),
                --VehicleBuyMenuEntry( 58, 2000 ),
                --VehicleBuyMenuEntry( 75, 1000 ),
                --VehicleBuyMenuEntry( 82, 1000 )
            },

            ["Sea"] = {
                VehicleBuyMenuEntry( 5, 500 ),
                VehicleBuyMenuEntry( 16, 500 ),
                VehicleBuyMenuEntry( 25, 700 ),
                VehicleBuyMenuEntry( 27, 1100 ),
                VehicleBuyMenuEntry( 28, 900 ),
                VehicleBuyMenuEntry( 69, 1000 ),
                VehicleBuyMenuEntry( 80, 1000 ),
                VehicleBuyMenuEntry( 88, 1050 ),
                -- DLC
                --VehicleBuyMenuEntry( 53, 10000 )
            },

            ["Air"] = {
                VehicleBuyMenuEntry( 3, 3000 ),
                VehicleBuyMenuEntry( 30, 8000 ),
                VehicleBuyMenuEntry( 34, 10000 ),
                VehicleBuyMenuEntry( 64, 4000 ),
                VehicleBuyMenuEntry( 65, 4000 ),
                VehicleBuyMenuEntry( 81, 5000 ),
                VehicleBuyMenuEntry( 85, 10000 ),
                -- DLC
                --VehicleBuyMenuEntry( 24, 15000 )
            }
        },

        [self.types.Weapon] = {
            { "One-handed", "Two-handed" },
            ["One-handed"] = {
                WeaponBuyMenuEntry( Weapon.Handgun, 500, 1, "Pistol" ),
                WeaponBuyMenuEntry( Weapon.Revolver, 1000, 1, "Revolver" ),
                WeaponBuyMenuEntry( Weapon.SMG, 1200, 1, "SMG" ),
                WeaponBuyMenuEntry( Weapon.SawnOffShotgun, 1100, 1, "Sawn-off Shotgun" )
            },

            ["Two-handed"] = {
                WeaponBuyMenuEntry( Weapon.Assault, 2000, 2, "Assault Rifle" ),
                WeaponBuyMenuEntry( Weapon.Shotgun, 2000, 2, "Shotgun" ),
                WeaponBuyMenuEntry( Weapon.MachineGun, 4000, 2, "Machine Gun" ),
                WeaponBuyMenuEntry( Weapon.Sniper, 5000, 2, "Sniper Rifle" ),
                WeaponBuyMenuEntry( Weapon.RocketLauncher, 7500, 2, "Rocket Launcher" )
            }
        },

        [self.types.Model] = {
            { "Roaches", "Ular Boys", "Reapers", "Government", "Agency", "Misc" },

            ["Roaches"] = {
                ModelBuyMenuEntry( 2, 5000, "Razak Razman" ),
                ModelBuyMenuEntry( 5, 2500, "Elite" ),
                ModelBuyMenuEntry( 32, 1250, "Technician" ),
                ModelBuyMenuEntry( 85, 600, "Soldier 1" ),
                ModelBuyMenuEntry( 59, 600, "Soldier 2" )
            },

            ["Ular Boys"] = {
                ModelBuyMenuEntry( 38, 5000, "Sri Irawan" ),
                ModelBuyMenuEntry( 87, 2500, "Elite" ),
                ModelBuyMenuEntry( 22, 1250, "Technician" ),
                ModelBuyMenuEntry( 27, 600, "Soldier 1" ),
                ModelBuyMenuEntry( 103, 600, "Soldier 2" )
            },

            ["Reapers"] = {
                ModelBuyMenuEntry( 90, 5000, "Bolo Santosi" ),
                ModelBuyMenuEntry( 63, 2500, "Elite" ),
                ModelBuyMenuEntry( 8, 1250, "Technician" ),
                ModelBuyMenuEntry( 12, 600, "Soldier 1" ),
                ModelBuyMenuEntry( 58, 600, "Soldier 2" ),
            },

            ["Government"] = {
                ModelBuyMenuEntry( 74, 7500, "Baby Panay" ),
                ModelBuyMenuEntry( 67, 7500, "Burned Baby Panay" ),
                ModelBuyMenuEntry( 101, 5000, "Colonel" ),
                ModelBuyMenuEntry( 3, 2500, "Demo Expert" ),
                ModelBuyMenuEntry( 98, 2500, "Pilot" ),
                ModelBuyMenuEntry( 42, 2500, "Black Hand" ),
                ModelBuyMenuEntry( 44, 2500, "Ninja" ),
                ModelBuyMenuEntry( 23, 1250, "Scientist" ),
                ModelBuyMenuEntry( 52, 600, "Soldier 1" ),
                ModelBuyMenuEntry( 66, 600, "Soldier 2" ) 
            },

            ["Agency"] = {
                ModelBuyMenuEntry( 9, 1000, "Karl Blaine" ),
                ModelBuyMenuEntry( 65, 1000, "Jade Tan" ),
                ModelBuyMenuEntry( 25, 1000, "Maria Kane" ),
                ModelBuyMenuEntry( 30, 1000, "Marshall" ),
                ModelBuyMenuEntry( 34, 1000, "Tom Sheldon" ),
                ModelBuyMenuEntry( 100, 1000, "Black Market Dealer" ),
                ModelBuyMenuEntry( 83, 800, "White Tiger" ),
                ModelBuyMenuEntry( 51, 0, "Rico Rodriguez" )
            },

            ["Misc"] = {
                ModelBuyMenuEntry( 70, 5000, "General Masayo" ),
                ModelBuyMenuEntry( 11, 5000, "Zhang Sun" ),
                ModelBuyMenuEntry( 84, 5000, "Alexander Mirikov" ),
                ModelBuyMenuEntry( 19, 5000, "Chinese Businessman" ),
                ModelBuyMenuEntry( 36, 5000, "Politician" ),
                ModelBuyMenuEntry( 78, 4000, "Thug Boss" ),
                ModelBuyMenuEntry( 71, 2500, "Saul Sukarno" ),
                ModelBuyMenuEntry( 79, 2500, "Japanese Veteran" ),
                ModelBuyMenuEntry( 96, 2500, "Bodyguard" ),
                ModelBuyMenuEntry( 80, 2500, "Suited Guest 1" ),
                ModelBuyMenuEntry( 95, 2500, "Suited Guest 2" ),
                ModelBuyMenuEntry( 60, 1250, "Race Challenge Girl" ),
                ModelBuyMenuEntry( 15, 1250, "Male Stripper 1" ),
                ModelBuyMenuEntry( 17, 1250, "Male Stripper 2" ),
                ModelBuyMenuEntry( 86, 1250, "Female Stripper" ),
                ModelBuyMenuEntry( 16, 1250, "Panau Police" ),
                ModelBuyMenuEntry( 18, 1250, "Hacker" ),
                ModelBuyMenuEntry( 64, 1000, "Bom Bom Bohilano" ),
                ModelBuyMenuEntry( 40, 1000, "Factory Boss" ),
                ModelBuyMenuEntry( 1, 600, "Thug 1" ),
                ModelBuyMenuEntry( 39, 600, "Thug 2" ),
                ModelBuyMenuEntry( 61, 600, "Soldier" ),
                ModelBuyMenuEntry( 26, 600, "Boat Captain" ),
                ModelBuyMenuEntry( 21, 20, "Paparazzi" ),
            }
        }
    }
end