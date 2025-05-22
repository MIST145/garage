Config = {}

Config.VehicleMenu = false -- enable this if you wan't a vehicle menu. 
--Above disabled by DeadlyEmu#0001 This function is buggy and i CBA to fix it. there is better resources out there which does this job
Config.VehicleMenuButton = 344 -- change this to the key you want to open the menu with. buttons: https://docs.fivem.net/game-references/controls/
Config.RangeCheck = 25.0 -- this is the change you will be able to control the vehicle.

Config.Impound = true --Enable/Disable impound feature
Config.ImpoundPrice = 200 --Price it will cost player to recover vehicle
Config.ImpoundName = "Apreendidos" --Name to show on blip
Config.RebootRestore = false --send all cars back to the garage on restart of the resource?
Config.ImpoundAutoBan = true --Autoban player if exploit is discovered? (Trying to put car in garage via lua executor) Requires EasyAdmin
Config.AutoBanMessage = "You have been banned for exploiting the the impound system DeadlyEmu#0001" -- Ban message to show

Config.LockGarage = true --True restrict garage(store in one cnat take it out the other) False can take all cars out of all garages



Config.BlipImpound = {
    Sprite = 527,
    Color = 60,
    Display = 2,
    Scale = 0.7
}

Config.DrawDistance = 100.0

--Impounds

Config.CarPounds = {
    Pound_LosSantos = {
        PoundPoint = { x = 408.61, y = -1625.47, z = 28.29 },
        SpawnPoint = { x = 405.64, y = -1643.4, z = 27.61, h = 229.54 }
    },
    
    Pound_Sandy = {
        PoundPoint = { x = 1651.38, y = 3804.84, z = 37.65 },
        SpawnPoint = { x = 1627.84, y = 3788.45, z = 33.77, h = 308.53 }
    },
    
    Pound_Paleto = {
        PoundPoint = { x = -234.82, y = 6198.65, z = 30.94 },
        SpawnPoint = { x = -230.08, y = 6190.24, z = 30.49, h = 140.24 }
    }
}

Config.PoundMarker = {
    r = 0, g = 0, b = 100,     -- Blue Color
    x = 1.5, y = 1.5, z = 1.0  -- Standard Size Circle
}




--Garages
Config.Garages = {
    ["PRAÇA"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(213.80894470215, -915.26812744141, 18.319723129272)
            },
            ["vehicle"] = {
                ["position"] = vector3(219.54042053223, -902.52001953125, 17.786388397217), 
                ["heading"] = 235.12057495117
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
            ["x"] = 213.80894470215, 
            ["y"] = -915.26812744141, 
            ["z"] = 18.319723129272, 
            ["rotationX"] = -31.401574149728, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -243.40157422423 
        }
    },

    ["B"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(273.67422485352, -344.15573120117, 44.919834136963)
            },
            ["vehicle"] = {
                ["position"] = vector3(272.50082397461, -337.40579223633, 44.919834136963), 
                ["heading"] = 160.0
            }
        },
        ["camera"] = { 
            ["x"] = 283.28225708008, 
            ["y"] = -333.24017333984, 
            ["z"] = 50.004745483398, 
            ["rotationX"] = -21.637795701623, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = 125.73228356242 
        }
    },

    ["C"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-1803.8967285156, -341.45928955078, 43.986347198486)
            },
            ["vehicle"] = {
                ["position"] = vector3(-1810.7857666016, -337.13592529297, 43.552074432373), 
                ["heading"] = 320.0
            }
        },
        ["camera"] = { 
            ["x"] = -1813.5513916016, 
            ["y"] = -340.40087890625, 
            ["z"] = 46.962894439697, 
            ["rotationX"] = -39.496062710881, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -42.110235854983 
        }
    },

    ["D"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-44.0, -1836.81, 26.23)
            },
            ["vehicle"] = {
                ["position"] = vector3(-44.71, -1840.23, 26.13), 
                ["heading"] = 320.0
            }
        },
        ["camera"] = { 
            ["x"] = -51.5513916016, 
            ["y"] = -1837.40087890625, 
            ["z"] = 30.962894439697, 
            ["rotationX"] = -35.496062710881, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -110.110235854983 
        }
    },

    ["E"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(105.08, 6613.58, 32.37)
            },
            ["vehicle"] = {
                ["position"] = vector3(107.89, 6606.66, 31.7), 
                ["heading"] = 320.0
            }
        },
        ["camera"] = { 
            ["x"] = 110.74, 
            ["y"] = 6614.71, 
            ["z"] = 33.962894439697, 
            ["rotationX"] = -35.496062710881, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -210.110235854983 
        }
    },

    ["F"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(1407.50, 3619.18, 34.9)
            },
            ["vehicle"] = {
                ["position"] = vector3(1416.2, 3622.7, 34.73), 
                ["heading"] = 201.07
            }
        },
        ["camera"] = { 
            ["x"] = 1420.1, 
            ["y"] = 3627.25, 
            ["z"] = 38.0, 
            ["rotationX"] = -35.496062710881, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -230.110235854983 
        }
    },

    ["G"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-340.89, 267.19, 85.62)
            },
            ["vehicle"] = {
                ["position"] = vector3(-349.86, 272.67, 84.95), 
                ["heading"] = 91.48
            }
        },
        ["camera"] = { 
            ["x"] = -358.44, 
            ["y"] = 276.18, 
            ["z"] = 90.0, 
            ["rotationX"] = -35.496062710881, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -100.110235854983 
        }
    },
    

    ["H"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-1041.81, -2598.47, 14.55)
            },
            ["vehicle"] = {
                ["position"] = vector3(-1037.55, -2593.97, 14.05), 
                ["heading"] = 61.01
            }
        },
        ["camera"] = { 
            ["x"] = -1034.07, 
            ["y"] = -2602.04, 
            ["z"] = 17.18, 
            ["rotationX"] = -35.496062710881, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -330.110235854983 
        }
    },
    

    ["I"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(1172.0, -1527.52, 34.99)
            },
            ["vehicle"] = {
                ["position"] = vector3(1180.97, -1535.66, 39.25), 
                ["heading"] = 0.42
            }
        },
        ["camera"] = { 
            ["x"] = 1187.53, 
            ["y"] = -1531.85, 
            ["z"] = 42.7, 
            ["rotationX"] = -35.496062710881, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -250.110235854983 
        }
    },
    

    ["J"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(1143.11, -462.3, 66.92)
            },
            ["vehicle"] = {
                ["position"] = vector3(1145.4, -471.16, 66.40), 
                ["heading"] = 254.42
            }
        },
        ["camera"] = { 
            ["x"] = 1144.35, 
            ["y"] = -477.37, 
            ["z"] = 70.7, 
            ["rotationX"] = -35.496062710881, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -350.110235854983 
        }
    },
    

    ["K"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-668.41, 638.46, 149.50)
            },
            ["vehicle"] = {
                ["position"] = vector3(-671.31, 645.51, 148.94), 
                ["heading"] = 261.12
            }
        },
        ["camera"] = { 
            ["x"] = -675.1, 
            ["y"] = 638.95, 
            ["z"] = 150.53, 
            ["rotationX"] = -35.496062710881, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -50.110235854983 
        }
    },
    

    ["L"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-1061.55, -1699.99, 4.42)
            },
            ["vehicle"] = {
                ["position"] = vector3(-1056.89, -1689.51, 4.30), 
                ["heading"] = 3.61
            }
        },
        ["camera"] = { 
            ["x"] = -1061.85, 
            ["y"] = -1686.71, 
            ["z"] = 8.53, 
            ["rotationX"] = -35.496062710881, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -150.110235854983 
        }
    }
}

Config.Labels = {
    ["menu"] = "~INPUT_CONTEXT~ abrir a garagem. %s.",
    ["vehicle"] = "'%s'ı para guardar o veículo ~INPUT_CONTEXT~"
}

Config.Trim = function(value)
    if value then
        return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
    else
        return nil
    end
end

Config.AlignMenu = "right" -- this is where the menu is located [left, right, center, top-right, top-left etc.]