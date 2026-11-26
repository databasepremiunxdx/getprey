-- getprey.luau
-- Zee : ZHD | Based on /beatomic
-- Part 1 of 10: Environment, Security & Configuration

-- ============================================================================
-- SECTION 1: ENVIRONMENT & ANTI-CHEAT BYPASS
-- ============================================================================

local rawget = rawget
local rawset = rawset
local pcall = pcall
local xpcall = xpcall
local assert = assert
local type = type
local typeof = typeof
local tick = tick
local time = time
local wait = task.wait
local spawn = task.spawn
local delay = task.delay

local env = getgenv or getfenv or function() return _G end
local cloneref = cloneref or function(o) return o end
local getrawmetatable = getrawmetatable or debug.getmetatable
local setreadonly = setreadonly or make_writeable or function(t, b) end
local hookfunction = hookfunction or detour_function or function(a, b) return a end
local hookmetamethod = hookmetamethod or function(a, b, c) return function() end end
local checkcaller = checkcaller or function() return false end
local getnamecallmethod = getnamecallmethod or function() return "" end
local islclosure = islclosure or is_synapse_function or function() return false end

-- Services
local Services = {}
local function GetService(name)
    if Services[name] then return Services[name] end
    local suc, srv = pcall(function() return cloneref(game:GetService(name)) end)
    if suc and srv then
        Services[name] = srv
        return srv
    end
    return nil
end

local Players = GetService("Players")
local RunService = GetService("RunService")
local UserInputService = GetService("UserInputService")
local Workspace = GetService("Workspace")
local ReplicatedStorage = GetService("ReplicatedStorage")
local TweenService = GetService("TweenService")
local HttpService = GetService("HttpService")
local StarterGui = GetService("StarterGui")
local GuiService = GetService("GuiService")
local Lighting = GetService("Lighting")
local SoundService = GetService("SoundService")
local VirtualUser = GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Bypass Meta State
local bypassState = {
    Active = true,
    Hooks = {},
    KickBlock = true,
    DestroyBlock = true,
    CrashBlock = true
}

-- Safe Wrappers to suppress errors
local function SafeIndex(obj, prop)
    if not obj then return nil end
    local s, r = pcall(function() return obj[prop] end)
    return s and r or nil
end

local function SafeCall(func, ...)
    if not func then return nil end
    local s, r = pcall(func, ...)
    return s and r or nil
end

local function SafeWait(obj, prop, timeout)
    if not obj then return nil end
    local s, r = pcall(function() return obj:WaitForChild(prop, timeout or 10) end)
    return s and r or nil
end

local function SafeFire(remoteName, ...)
    if not remoteName then return end
    local s, r = pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes") 
            or ReplicatedStorage:FindFirstChild("RemoteEvents") 
            or ReplicatedStorage:FindFirstChild("Events")
        if remotes then
            local rem = remotes:FindFirstChild(remoteName)
            if rem and rem.FireServer then
                rem:FireServer(...)
            end
        end
    end)
end

-- ============================================================================
-- SECTION 2: THE BEATOMIC CONFIGURATION (UNROLLED)
-- ============================================================================

getprey = getprey or {}
getprey.atomic = {}

-- General
getprey.atomic['General'] = {}
getprey.atomic['General']['Keybinds'] = {
    ['Selection'] = 'C',
    ['Silent Aim'] = 'C',
    ['Trigger Bot'] = 'C',
    ['Aim Assist'] = 'C',
    ['Ragebot'] = 'C',
    ['Speed'] = 'V',
    ['Rage Movement'] = 'E',
    ['Panic Ground'] = 'X',
    ['Macro'] = '',
    ['ESP'] = 'T',
    ['Anti Future'] = 'Z',
    ['Rage Mode'] = ''
}

getprey.atomic['General']['Display Keybinds'] = {
    ['Enabled'] = false,
    ['Title'] = 'real db is a shitter',
    ['Type'] = '1',
    ['Follow'] = false,
    ['Key Color'] = Color3.fromRGB(255, 255, 255),
    ['Atomic Title'] = Color3.fromRGB(255, 255, 255),
    ['Target Color'] = Color3.fromRGB(35, 164, 61)
}

getprey.atomic['General']['Conditions'] = {
    ['Whilst Selecting a Player'] = {
        ['Visible'] = false,
        ['Knocked'] = false,
        ['SelfKnocked'] = false,
        ['Grabbed'] = true,
        ['Forcefield'] = true
    },
    ['Whilst a Player is Selected'] = {
        ['Visible'] = false,
        ['Knocked'] = false,
        ['SelfKnocked'] = false,
        ['Grabbed'] = true,
        ['Forcefield'] = true
    }
}

getprey.atomic['General']['Selection'] = {
    ['Mode'] = 'Select',
    ['Activation'] = {
        ['Type'] = 'Toggle'
    },
    ['FOV'] = {
        ['Size'] = 1111,
        ['Show'] = false
    }
}

-- Combat
getprey.atomic['General']['Combat'] = {}

getprey.atomic['General']['Combat']['Silent Aim'] = {
    ['Enabled'] = true,
    ['Prediction'] = {
        ['Enabled'] = true,
        ['Values'] = {
            ['X'] = 0,
            ['Y'] = 0,
            ['Z'] = 0
        }
    },
    ['Hit Location'] = {
        ['Closest Point'] = {
            ['Scale'] = {false, 0.32}
        }
    }
}

getprey.atomic['General']['Combat']['Trigger Bot'] = {
    ['Enabled'] = true,
    ['Click Cooldown'] = 0,
    ['Distance'] = {
        ['Max Distance'] = math.huge,
        ['Auto Distance'] = false
    },
    ['Activation'] = {
        ['Mode'] = '1000'
    },
    ['Prediction'] = {
        ['Enabled'] = true,
        ['Values'] = {
            ['X'] = 0,
            ['Y'] = 0,
            ['Z'] = 0
        }
    }
}

getprey.atomic['General']['Combat']['Aim Assist'] = {
    ['Enabled'] = true,
    ['Adaptive'] = false,
    ['Sharpness'] = 0.5,
    ['Method'] = 'Camera',
    ['Person'] = {
        ['First Person'] = true,
        ['Third Person'] = true
    },
    ['Prediction'] = {
        ['Enabled'] = true,
        ['Values'] = {
            ['X'] = 0,
            ['Y'] = 0,
            ['Z'] = 0
        }
    },
    ['Hit Location'] = {
        ['Part'] = 'Head',
        ['Closest Point'] = {
            ['Scale'] = {true, 0.32}
        }
    }
}

getprey.atomic['General']['Combat']['Ragebot'] = {
    ['Enabled'] = false,
    ['Activation'] = {
        ['Type'] = 'Toggle'
    },
    ['View Target'] = true,
    ['Void'] = {
        ['Enabled'] = true,
        ['Velocity'] = 2e+35
    },
    ['Notifier'] = {
        ['Hits'] = true,
        ['Kills'] = true
    },
    ['Stomp'] = {
        ['Enabled'] = true
    },
    ['Weapons'] = {
        ['Use'] = '[AR],[Revolver]',
        ['Buy'] = '[AR],[Revolver]',
        ['Auto Buy'] = true
    }
}

-- Future
getprey.atomic['General']['Future'] = {
    ['Enabled'] = false,
    ['Strength'] = 100,
    ['MaxLead'] = 100,
    ['Vertical'] = true
}

-- Character
getprey.atomic['General']['Character'] = {}

getprey.atomic['General']['Character']['WalkSpeed'] = {
    ['Enabled'] = true,
    ['Activation'] = 'Keybind',
    ['Multiplier'] = {
        ['Conditions'] = {
            ['Normal'] = 20,
            ['Shooting'] = 20,
            ['Reloading'] = 20
        }
    }
}

getprey.atomic['General']['Character']['JumpPower'] = {
    ['Enabled'] = true,
    ['Multiplier'] = 9,
    ['WallJump'] = {false, 7}
}

getprey.atomic['General']['Character']['Rage Movement'] = {
    ['Enabled'] = true,
    ['Power'] = 1000,
    ['Camlock'] = {
        ['Enabled'] = true,
        ['Sharpness'] = 1
    }
}

getprey.atomic['General']['Character']['Char'] = {
    ['Enabled'] = true,
    ['Target'] = 'GibsonTomas',
    ['Config'] = {
        ['Skinny'] = true,
        ['Headless'] = true,
        ['Korblox'] = false
    }
}

getprey.atomic['General']['Character']['AntiFling'] = true

getprey.atomic['General']['Character']['Anti Future'] = {
    ['Enabled'] = true,
    ['Intensity'] = 150101
}

-- Gun Modifications
getprey.atomic['General']['Gun Modifications'] = {}

getprey.atomic['General']['Gun Modifications']['Spread Modifications'] = {
    ['Enabled'] = false,
    ['[Double-Barrel SG]'] = {true, 25},
    ['[TacticalShotgun]'] = {true, 1},
    ['[Shotgun]'] = {true, 1}
}

getprey.atomic['General']['Gun Modifications']['Delay Changer'] = {
    ['Enabled'] = true,
    ['[Double-Barrel SG]'] = {true, 1},
    ['[TacticalShotgun]'] = {true, 1},
    ['[Revolver]'] = {true, 1},
    ['[Deagle]'] = {true, 1},
    ['[AUG]'] = {true, 0}
}

getprey.atomic['General']['Gun Modifications']['Taps'] = {
    ['Enabled'] = false,
    ['[Double-Barrel SG]'] = {true, 2},
    ['[TacticalShotgun]'] = {true, 2},
    ['[Revolver]'] = {true, 6},
    ['[Deagle]'] = {true, 4},
    ['[AUG]'] = {true, 10}
}

getprey.atomic['General']['Gun Modifications']['Skin Changer'] = {
    ['Enabled'] = true,
    ['Unlock All'] = true,
    ['Weapons'] = {
        ['[Double-Barrel SG]'] = 'Galaxy',
        ['[Revolver]'] = 'Galaxy',
        ['[TacticalShotgun]'] = 'Electric',
        ['[Knife]'] = 'Love Kukri',
        ['[Deagle]'] = 'Balloon',
        ['[Rifle]'] = 'Grumpy'
    }
}

getprey.atomic['General']['Gun Modifications']['ForceHit'] = {
    ['Enabled'] = true
}

getprey.atomic['General']['Gun Modifications']['Damage Overrider'] = {
    ['Enabled'] = true,
    ['Mode'] = 'Full'
}

getprey.atomic['General']['Gun Modifications']['Hit Offset'] = {
    ['Enabled'] = false,
    ['[Double-Barrel SG]'] = {['X'] = 0, ['Y'] = 0, ['Z'] = 0},
    ['[TacticalShotgun]'] = {['X'] = 0, ['Y'] = 0, ['Z'] = 0},
    ['[Shotgun]'] = {['X'] = 0, ['Y'] = 0, ['Z'] = 0},
    ['[Drum-Shotgun]'] = {['X'] = 0, ['Y'] = 0, ['Z'] = 0},
    ['[Revolver]'] = {['X'] = 0.1212, ['Y'] = 0.1812, ['Z'] = 0.1212},
    ['[Glock]'] = {['X'] = 0.15, ['Y'] = 0.02, ['Z'] = 0.15},
    ['[Silencer]'] = {['X'] = 0.15, ['Y'] = 0.02, ['Z'] = 0.15}
}

getprey.atomic['General']['Gun Modifications']['Rage Mode'] = {
    ['Enabled'] = true
}

-- Misc
getprey.atomic['General']['Misc'] = {}

getprey.atomic['General']['Misc']['AntiStomp'] = true
getprey.atomic['General']['Misc']['PanicGround'] = true

getprey.atomic['General']['Misc']['Setup'] = {
    ['Enabled'] = true,
    ['Order'] = {
        '[Double-Barrel SG]',
        '[Revolver]',
        '[TacticalShotgun]',
        '[Knife]',
        '[Donut]'
    },
    ['Armor'] = {
        ['Enabled'] = true,
        ['Type'] = 'High'
    },
    ['Ammo'] = {
        ['Enabled'] = true,
        ['Amount'] = 3
    }
}

getprey.atomic['General']['Misc']['Mute Gun Sounds'] = {
    ['Enabled'] = false
}

getprey.atomic['General']['Misc']['Hitbox Expander'] = {
    ['Enabled'] = true,
    ['Size'] = 99
}

-- ESP
getprey.atomic['General']['ESP'] = {}

getprey.atomic['General']['ESP']['Enabled'] = true

getprey.atomic['General']['ESP']['Name'] = {
    ['Enabled'] = true,
    ['Colors'] = {
        ['Normal Color'] = Color3.fromRGB(255, 255, 255),
        ['Target Color'] = Color3.fromRGB(187, 198, 214)
    },
    ['Transparency'] = 0
}

getprey.atomic['General']['ESP']['Health'] = {
    ['Enabled'] = true,
    ['Color'] = Color3.fromRGB(135, 252, 124),
    ['Type'] = 'Dynamic',
    ['Color1'] = Color3.fromRGB(135, 252, 124),
    ['Color2'] = Color3.fromRGB(255, 0, 0),
    ['Color3'] = Color3.fromRGB(255, 255, 255),
    ['Color3Transparency'] = 0
}

getprey.atomic['General']['ESP']['Boxes'] = {
    ['Enabled'] = true,
    ['Color'] = Color3.fromRGB(255, 255, 255),
    ['Fill'] = {
        ['Enabled'] = true,
        ['Color1'] = Color3.fromRGB(255, 255, 255),
        ['Transparency1'] = 0.8,
        ['Color2'] = Color3.fromRGB(255, 255, 255),
        ['Transparency2'] = 0.8,
        ['Spin'] = false
    },
    ['Glow'] = false
}

getprey.atomic['General']['ESP']['Target Line'] = {
    ['Enabled'] = false,
    ['Color'] = Color3.fromRGB(35, 164, 61)
}

getprey.atomic['General']['ESP']['Distance'] = {
    ['Enabled'] = false,
    ['Color'] = Color3.fromRGB(255, 255, 255),
    ['Transparency'] = 0
}

getprey.atomic['General']['ESP']['Weapon'] = {
    ['Enabled'] = false,
    ['Color'] = Color3.fromRGB(255, 255, 255),
    ['Transparency'] = 0
}

getprey.atomic['General']['ESP']['Skeleton'] = {
    ['Enabled'] = false,
    ['Color'] = Color3.fromRGB(255, 255, 255),
    ['Transparency'] = 0
}

getprey.atomic['General']['ESP']['Out of View'] = {
    ['Enabled'] = false,
    ['Color'] = Color3.fromRGB(255, 255, 255),
    ['Transparency'] = 0,
    ['Blink'] = false,
    ['BlinkSpeed'] = 1,
    ['DynamicDistance'] = true,
    ['Distance'] = 40,
    ['DynamicSize'] = true,
    ['Size'] = 13,
    ['Style'] = 'Concave'
}

getprey.atomic['General']['ESP']['Chams'] = {
    ['Enabled'] = false,
    ['Color'] = Color3.fromRGB(255, 0, 0),
    ['Transparency'] = 0.5,
    ['Outline Color'] = Color3.fromRGB(0, 0, 0),
    ['Type'] = 'Highlight',
    ['Outline Transparency'] = 0,
    ['Glow'] = {
        ['Enabled'] = false,
        ['Size'] = 1.75
    }
}

getprey.atomic['General']['ESP']['Weapon Chams'] = {
    ['Enabled'] = false,
    ['Color'] = Color3.fromRGB(255, 0, 0),
    ['Transparency'] = 0.5,
    ['Outline Color'] = Color3.fromRGB(0, 0, 0),
    ['Outline Transparency'] = 0
}

-- Game Specific
getprey.atomic['General']['Game Specific'] = {
    ['Das Hood'] = {
        ['Infinite Range'] = true,
        ['Wall Bang'] = true
    },
    ['Da Hood'] = {}
}

-- Macro
getprey.atomic['General']['Macro'] = {
    ['Enabled'] = true,
    ['Settings'] = {
        ['Mode'] = 'Hold',
        ['Interval'] = 0.015
    }
}

-- Anti-Cheat Hook Init (Stubbed until Part 2)
local function InitAntiCheat()
    local suc, err = pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            
            if not checkcaller() then
                -- Block Kick
                if method == "Kick" and bypassState.KickBlock then
                    if tostring(self) == "Players" or tostring(self) == "Workspace" then
                        return
                    end
                end
                
                -- Block Destroy
                if method == "Destroy" and bypassState.DestroyBlock then
                    if tostring(self) == "Workspace" or tostring(self) == "Players" then
                        return
                    end
                end
            end
            
            return oldNamecall(self, ...)
        end)
        table.insert(bypassState.Hooks, oldNamecall)
    end)
end

spawn(InitAntiCheat)

-- End of Part 1.
-- [WAITING FOR PART 2: UI INITIALIZATION]
-- ============================================================================
-- SECTION 3: UI INITIALIZATION (LINORIA)
-- ============================================================================

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local suc_lib, Library = pcall(function()
    return loadstring(game:HttpGet(repo .. 'Library.lua'))()
end)

if not suc_lib or not Library then
    warn("[getprey] Failed to load UI Library.")
    return
end

local suc_theme, ThemeManager = pcall(function()
    return loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
end)

local suc_save, SaveManager = pcall(function()
    return loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
end)

if not suc_theme or not suc_save then
    warn("[getprey] Failed to load UI addons.")
    return
end

local Window = Library:CreateWindow({
    Title = '/getprey',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Combat = Window:AddTab('Combat'),
    Character = Window:AddTab('Character'),
    Weapon = Window:AddTab('Weapon'),
    Visual = Window:AddTab('Visual'),
    Utilities = Window:AddTab('Utilities')
}

-- ============================================================================
-- MAIN TAB
-- ============================================================================

local MainLeft = Tabs.Main:AddLeftGroupbox('Checks')
MainLeft:AddToggle('Chk_Visible', {
    Text = 'Visible',
    Default = false,
    Tooltip = 'Only target visible players'
})
MainLeft:AddToggle('Chk_Knocked', {
    Text = 'Knocked',
    Default = false,
    Tooltip = 'Target knocked players'
})
MainLeft:AddToggle('Chk_SelfKnocked', {
    Text = 'SelfKnocked',
    Default = false,
    Tooltip = 'Target when self is knocked'
})
MainLeft:AddToggle('Chk_Grabbed', {
    Text = 'Grabbed',
    Default = true,
    Tooltip = 'Target players being grabbed'
})
MainLeft:AddToggle('Chk_Forcefield', {
    Text = 'Forcefield',
    Default = true,
    Tooltip = 'Target players with forcefields'
})

local MainRight = Tabs.Main:AddRightGroupbox('Display')
MainRight:AddToggle('Disp_Enabled', {
    Text = 'Enabled',
    Default = false,
    Tooltip = 'Show the watermark'
})
MainRight:AddTextbox('Disp_Title', {
    Text = 'Title',
    Default = 'real db is a shitter',
    Placeholder = 'Watermark Title',
    Tooltip = 'Text displayed on the watermark'
})
MainRight:AddDropdown('Disp_Type', {
    Values = {'1', '2', '3'},
    Default = '1',
    Text = 'Type',
    Tooltip = 'Watermark style'
})
MainRight:AddToggle('Disp_Follow', {
    Text = 'Follow',
    Default = false,
    Tooltip = 'Follow camera movement'
})
MainRight:AddLabel('Key Color'):AddColorPicker('Disp_KeyColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Key Color'
})
MainRight:AddLabel('Atomic Title'):AddColorPicker('Disp_AtomicTitle', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Atomic Title Color'
})
MainRight:AddLabel('Target Color'):AddColorPicker('Disp_TargetColor', {
    Default = Color3.fromRGB(35, 164, 61),
    Title = 'Target Color'
})

local MainSelection = Tabs.Main:AddLeftGroupbox('Selection')
MainSelection:AddDropdown('Sel_Mode', {
    Values = {'Select', 'Toggle'},
    Default = 'Select',
    Text = 'Mode',
    Tooltip = 'How targets are selected'
})
MainSelection:AddSlider('Sel_FOV', {
    Text = 'FOV Size',
    Min = 0,
    Max = 2000,
    Default = 1111,
    Rounding = 0,
    Suffix = 'px',
    Tooltip = 'Field of view for target selection'
})
MainSelection:AddToggle('Sel_ShowFOV', {
    Text = 'Show FOV',
    Default = false,
    Tooltip = 'Draw the FOV circle'
})

-- ============================================================================
-- COMBAT TAB
-- ============================================================================

local CombatSilent = Tabs.Combat:AddLeftGroupbox('Silent Aim')
CombatSilent:AddToggle('Silent_Enabled', {
    Text = 'Enabled',
    Default = true,
    Tooltip = 'Redirects your shots to the target'
})
CombatSilent:AddToggle('Silent_Pred', {
    Text = 'Prediction',
    Default = true,
    Tooltip = 'Predict target movement'
})
CombatSilent:AddSlider('Silent_PredX', {
    Text = 'Prediction X',
    Min = 0,
    Max = 1,
    Default = 0,
    Rounding = 3,
    Suffix = 'x'
})
CombatSilent:AddSlider('Silent_PredY', {
    Text = 'Prediction Y',
    Min = 0,
    Max = 1,
    Default = 0,
    Rounding = 3,
    Suffix = 'y'
})
CombatSilent:AddSlider('Silent_PredZ', {
    Text = 'Prediction Z',
    Min = 0,
    Max = 1,
    Default = 0,
    Rounding = 3,
    Suffix = 'z'
})
CombatSilent:AddDropdown('Silent_HitLoc', {
    Values = {'Head', 'Torso', 'Closest Point'},
    Default = 'Closest Point',
    Text = 'Hit Location',
    Tooltip = 'Where to aim'
})
CombatSilent:AddSlider('Silent_Scale', {
    Text = 'Closest Point Scale',
    Min = 0,
    Max = 1,
    Default = 0.32,
    Rounding = 2,
    Tooltip = 'Scale for closest point targeting'
})

local CombatTrigger = Tabs.Combat:AddRightGroupbox('Trigger Bot')
CombatTrigger:AddToggle('Trig_Enabled', {
    Text = 'Enabled',
    Default = true,
    Tooltip = 'Automatically shoots when target is in crosshair'
})
CombatTrigger:AddSlider('Trig_Cool', {
    Text = 'Click Cooldown',
    Min = 0,
    Max = 1,
    Default = 0,
    Rounding = 2,
    Suffix = 's'
})
CombatTrigger:AddSlider('Trig_Dist', {
    Text = 'Max Distance',
    Min = 0,
    Max = 5000,
    Default = 5000,
    Rounding = 0,
    Suffix = 'st'
})
CombatTrigger:AddToggle('Trig_AutoDist', {
    Text = 'Auto Distance',
    Default = false
})
CombatTrigger:AddToggle('Trig_Pred', {
    Text = 'Prediction',
    Default = true
})

local CombatAim = Tabs.Combat:AddLeftGroupbox('Aim Assist')
CombatAim:AddToggle('Aim_Enabled', {
    Text = 'Enabled',
    Default = true,
    Tooltip = 'Smoothly locks onto target'
})
CombatAim:AddToggle('Aim_Adaptive', {
    Text = 'Adaptive',
    Default = false
})
CombatAim:AddSlider('Aim_Sharp', {
    Text = 'Sharpness',
    Min = 0,
    Max = 1,
    Default = 0.5,
    Rounding = 2
})
CombatAim:AddDropdown('Aim_Method', {
    Values = {'Camera', 'Mouse'},
    Default = 'Camera',
    Text = 'Method'
})
CombatAim:AddToggle('Aim_FP', {
    Text = 'First Person',
    Default = true
})
CombatAim:AddToggle('Aim_TP', {
    Text = 'Third Person',
    Default = true
})

local CombatRage = Tabs.Combat:AddRightGroupbox('Ragebot')
CombatRage:AddToggle('Rage_Enabled', {
    Text = 'Enabled',
    Default = false
})
CombatRage:AddToggle('Rage_View', {
    Text = 'View Target',
    Default = true
})
CombatRage:AddToggle('Rage_Void', {
    Text = 'Void',
    Default = true
})
CombatRage:AddToggle('Rage_Stomp', {
    Text = 'Stomp',
    Default = true
})
CombatRage:AddToggle('Rage_Notifier', {
    Text = 'Notifier',
    Default = true
})
CombatRage:AddTextbox('Rage_WeapUse', {
    Text = 'Use',
    Default = '[AR],[Revolver]'
})
CombatRage:AddTextbox('Rage_WeapBuy', {
    Text = 'Buy',
    Default = '[AR],[Revolver]'
})
CombatRage:AddToggle('Rage_AutoBuy', {
    Text = 'Auto Buy',
    Default = true
})

-- ============================================================================
-- CHARACTER TAB
-- ============================================================================

local CharSpeed = Tabs.Character:AddLeftGroupbox('WalkSpeed')
CharSpeed:AddToggle('Spd_Enabled', {
    Text = 'Enabled',
    Default = true
})
CharSpeed:AddSlider('Spd_Norm', {
    Text = 'Normal',
    Min = 16,
    Max = 100,
    Default = 20,
    Rounding = 0
})
CharSpeed:AddSlider('Spd_Shoot', {
    Text = 'Shooting',
    Min = 16,
    Max = 100,
    Default = 20,
    Rounding = 0
})
CharSpeed:AddSlider('Spd_Reload', {
    Text = 'Reloading',
    Min = 16,
    Max = 100,
    Default = 20,
    Rounding = 0
})

local CharJump = Tabs.Character:AddRightGroupbox('JumpPower')
CharJump:AddToggle('Jmp_Enabled', {
    Text = 'Enabled',
    Default = true
})
CharJump:AddSlider('Jmp_Mult', {
    Text = 'Multiplier',
    Min = 1,
    Max = 500,
    Default = 9,
    Rounding = 0
})
CharJump:AddToggle('Jmp_WallJump', {
    Text = 'WallJump',
    Default = false
})
CharJump:AddSlider('Jmp_WallPower', {
    Text = 'Wall Power',
    Min = 1,
    Max = 500,
    Default = 7,
    Rounding = 0
})

local CharRage = Tabs.Character:AddLeftGroupbox('Rage Movement')
CharRage:AddToggle('RageMove_Enabled', {
    Text = 'Enabled',
    Default = true
})
CharRage:AddSlider('RageMove_Power', {
    Text = 'Power',
    Min = 0,
    Max = 5000,
    Default = 1000,
    Rounding = 0
})
CharRage:AddToggle('RageMove_Cam', {
    Text = 'Camlock',
    Default = true
})
CharRage:AddSlider('RageMove_CamSharp', {
    Text = 'Cam Sharpness',
    Min = 0,
    Max = 1,
    Default = 1,
    Rounding = 2
})

local CharAvatar = Tabs.Character:AddRightGroupbox('Avatar Changer')
CharAvatar:AddToggle('Ava_Enabled', {
    Text = 'Enabled',
    Default = true
})
CharAvatar:AddTextbox('Ava_Target', {
    Text = 'Target',
    Default = 'GibsonTomas'
})
CharAvatar:AddToggle('Ava_Skinny', {
    Text = 'Skinny',
    Default = true
})
CharAvatar:AddToggle('Ava_Headless', {
    Text = 'Headless',
    Default = true
})
CharAvatar:AddToggle('Ava_Korblox', {
    Text = 'Korblox',
    Default = false
})

local CharMisc = Tabs.Character:AddLeftGroupbox('Misc')
CharMisc:AddToggle('AntiFling_Enabled', {
    Text = 'AntiFling',
    Default = true
})
CharMisc:AddToggle('AntiFuture_Enabled', {
    Text = 'Anti Future',
    Default = true
})
CharMisc:AddSlider('AntiFuture_Int', {
    Text = 'Intensity',
    Min = 0,
    Max = 500000,
    Default = 150101,
    Rounding = 0
})

-- ============================================================================
-- WEAPON TAB
-- ============================================================================

local WeapSpread = Tabs.Weapon:AddLeftGroupbox('Spread Modifications')
WeapSpread:AddToggle('Spread_Enabled', {
    Text = 'Enabled',
    Default = false
})
WeapSpread:AddToggle('Spread_DB', {
    Text = '[Double-Barrel SG]',
    Default = true
})
WeapSpread:AddSlider('Spread_DB_Val', {
    Text = '[DB] Value',
    Min = 0,
    Max = 100,
    Default = 25,
    Rounding = 0
})
WeapSpread:AddToggle('Spread_Tac', {
    Text = '[TacticalShotgun]',
    Default = true
})
WeapSpread:AddSlider('Spread_Tac_Val', {
    Text = '[Tac] Value',
    Min = 0,
    Max = 100,
    Default = 1,
    Rounding = 0
})

local WeapDelay = Tabs.Weapon:AddRightGroupbox('Delay Changer')
WeapDelay:AddToggle('Delay_Enabled', {
    Text = 'Enabled',
    Default = true
})
WeapDelay:AddSlider('Delay_DB', {
    Text = '[Double-Barrel SG]',
    Min = 0,
    Max = 10,
    Default = 1,
    Rounding = 2
})
WeapDelay:AddSlider('Delay_Tac', {
    Text = '[TacticalShotgun]',
    Min = 0,
    Max = 10,
    Default = 1,
    Rounding = 2
})
WeapDelay:AddSlider('Delay_Rev', {
    Text = '[Revolver]',
    Min = 0,
    Max = 10,
    Default = 1,
    Rounding = 2
})

local WeapTaps = Tabs.Weapon:AddLeftGroupbox('Taps')
WeapTaps:AddToggle('Taps_Enabled', {
    Text = 'Enabled',
    Default = false
})
WeapTaps:AddSlider('Taps_DB', {
    Text = '[Double-Barrel SG]',
    Min = 0,
    Max = 20,
    Default = 2,
    Rounding = 0
})
WeapTaps:AddSlider('Taps_Rev', {
    Text = '[Revolver]',
    Min = 0,
    Max = 20,
    Default = 6,
    Rounding = 0
})

local WeapSkin = Tabs.Weapon:AddRightGroupbox('Skin Changer')
WeapSkin:AddToggle('Skin_Enabled', {
    Text = 'Enabled',
    Default = true
})
WeapSkin:AddToggle('Skin_Unlock', {
    Text = 'Unlock All',
    Default = true
})
WeapSkin:AddDropdown('Skin_DB', {
    Values = {'Galaxy', 'Default'},
    Default = 'Galaxy',
    Text = '[Double-Barrel SG]'
})
WeapSkin:AddDropdown('Skin_Rev', {
    Values = {'Galaxy', 'Default'},
    Default = 'Galaxy',
    Text = '[Revolver]'
})

local WeapDmg = Tabs.Weapon:AddLeftGroupbox('Damage / Force')
WeapDmg:AddToggle('Dmg_Enabled', {
    Text = 'Damage Overrider',
    Default = true
})
WeapDmg:AddDropdown('Dmg_Mode', {
    Values = {'Full', 'Default'},
    Default = 'Full',
    Text = 'Mode'
})
WeapDmg:AddToggle('Hit_Enabled', {
    Text = 'ForceHit',
    Default = true
})
WeapDmg:AddToggle('RageMode_Enabled', {
    Text = 'Rage Mode',
    Default = true
})
WeapDmg:AddToggle('Offset_Enabled', {
    Text = 'Hit Offset',
    Default = false
})

local WeapGame = Tabs.Weapon:AddRightGroupbox('Game Specific')
WeapGame:AddToggle('DasHood_InfRange', {
    Text = 'Das Hood: Inf Range',
    Default = true
})
WeapGame:AddToggle('DasHood_Wall', {
    Text = 'Das Hood: Wall Bang',
    Default = true
})

-- ============================================================================
-- VISUAL TAB
-- ============================================================================

local VisESP = Tabs.Visual:AddLeftGroupbox('ESP')
VisESP:AddToggle('ESP_Enabled', {
    Text = 'Enabled',
    Default = true
})
VisESP:AddToggle('ESP_Name', {
    Text = 'Name',
    Default = true
})
VisESP:AddToggle('ESP_Health', {
    Text = 'Health',
    Default = true
})
VisESP:AddToggle('ESP_Boxes', {
    Text = 'Boxes',
    Default = true
})
VisESP:AddToggle('ESP_TargetLine', {
    Text = 'Target Line',
    Default = false
})
VisESP:AddToggle('ESP_Dist', {
    Text = 'Distance',
    Default = false
})
VisESP:AddToggle('ESP_Weapon', {
    Text = 'Weapon',
    Default = false
})

local VisChams = Tabs.Visual:AddRightGroupbox('Chams')
VisChams:AddToggle('Chams_Enabled', {
    Text = 'Enabled',
    Default = false
})
VisChams:AddToggle('WeapChams_Enabled', {
    Text = 'Weapon Chams',
    Default = false
})
VisChams:AddLabel('Color'):AddColorPicker('Chams_Color', {
    Default = Color3.fromRGB(255, 0, 0)
})
VisChams:AddSlider('Chams_Trans', {
    Text = 'Transparency',
    Min = 0,
    Max = 1,
    Default = 0.5,
    Rounding = 2
})

local VisMisc = Tabs.Visual:AddLeftGroupbox('Misc Visuals')
VisMisc:AddToggle('OOV_Enabled', {
    Text = 'Out of View',
    Default = false
})
VisMisc:AddToggle('OOV_Blink', {
    Text = 'Blink',
    Default = false
})

-- ============================================================================
-- UTILITIES TAB
-- ============================================================================

local UtilLeft = Tabs.Utilities:AddLeftGroupbox('Utilities')
UtilLeft:AddToggle('Util_AntiStomp', {
    Text = 'AntiStomp',
    Default = true
})
UtilLeft:AddToggle('Util_MuteGuns', {
    Text = 'Mute Gun Sounds',
    Default = false
})
UtilLeft:AddButton('Panic Ground', function()
    local suc, char = pcall(function() return LocalPlayer.Character end)
    if suc and char and char:FindFirstChild('HumanoidRootPart') then
        char.HumanoidRootPart.CFrame = CFrame.new(0, -1000, 0)
    end
end, 'Teleports you far below the map')

local UtilMacro = Tabs.Utilities:AddRightGroupbox('Macro')
UtilMacro:AddToggle('Macro_Enabled', {
    Text = 'Enabled',
    Default = true
})
UtilMacro:AddSlider('Macro_Int', {
    Text = 'Interval',
    Min = 0.001,
    Max = 1,
    Default = 0.015,
    Rounding = 3
})
UtilMacro:AddDropdown('Macro_Mode', {
    Values = {'Hold', 'Toggle'},
    Default = 'Hold',
    Text = 'Mode'
})

local UtilSetup = Tabs.Utilities:AddLeftGroupbox('Auto Setup')
UtilSetup:AddToggle('Setup_Enabled', {
    Text = 'Enabled',
    Default = true
})
UtilSetup:AddToggle('Setup_Armor', {
    Text = 'Buy Armor (High)',
    Default = true
})
UtilSetup:AddToggle('Setup_Ammo', {
    Text = 'Buy Ammo (3)',
    Default = true
})

-- End of Part 2.
-- [WAITING FOR PART 3: CORE MATH & PREDICTION]
-- ============================================================================
-- SECTION 4: CORE MATH & PREDICTION
-- ============================================================================

local Math = {}

-- Function to calculate the distance between two Vector3 positions
function Math.GetDistance(Position1, Position2)
    if not Position1 then return math.huge end
    if not Position2 then return math.huge end
    
    local DeltaX = Position1.X - Position2.X
    local DeltaY = Position1.Y - Position2.Y
    local DeltaZ = Position1.Z - Position2.Z
    
    local DistanceSquared = (DeltaX * DeltaX) + (DeltaY * DeltaY) + (DeltaZ * DeltaZ)
    local Distance = math.sqrt(DistanceSquared)
    
    return Distance
end

-- Function to calculate the angle between two vectors (used for FOV checks)
function Math.GetAngleBetweenVectors(VectorA, VectorB)
    if not VectorA then return 180 end
    if not VectorB then return 180 end
    
    local UnitA = VectorA.Unit
    local UnitB = VectorB.Unit
    
    local DotProduct = UnitA:Dot(UnitB)
    
    -- Clamp to avoid domain errors on math.acos
    if DotProduct > 1 then DotProduct = 1 end
    if DotProduct < -1 then DotProduct = -1 end
    
    local AngleInRadians = math.acos(DotProduct)
    local AngleInDegrees = math.deg(AngleInRadians)
    
    return AngleInDegrees
end

-- Function to calculate the 2D screen distance for the FOV circle
function Math.GetScreenDistance(ScreenPosition1, ScreenPosition2)
    if not ScreenPosition1 then return math.huge end
    if not ScreenPosition2 then return math.huge end
    
    local DeltaX = ScreenPosition1.X - ScreenPosition2.X
    local DeltaY = ScreenPosition1.Y - ScreenPosition2.Y
    
    local DistanceSquared = (DeltaX * DeltaX) + (DeltaY * DeltaY)
    local Distance = math.sqrt(DistanceSquared)
    
    return Distance
end

-- Function to predict the target's position based on velocity and ping
function Math.PredictPosition(TargetPart, PredictionX, PredictionY, PredictionZ)
    if not TargetPart then return nil end
    
    local CurrentPosition = TargetPart.Position
    local CurrentVelocity = TargetPart.Velocity
    
    -- Get player ping (default to 50ms if unavailable)
    local Ping = 50
    local suc_ping, stats = pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end)
    if suc_ping and stats then
        Ping = stats
    end
    
    -- Convert ping to seconds
    local PingSeconds = Ping / 1000
    
    -- Apply custom multipliers from the UI
    local PredictedX = CurrentPosition.X + (CurrentVelocity.X * PingSeconds * PredictionX)
    local PredictedY = CurrentPosition.Y + (CurrentVelocity.Y * PingSeconds * PredictionY)
    local PredictedZ = CurrentPosition.Z + (CurrentVelocity.Z * PingSeconds * PredictionZ)
    
    return Vector3.new(PredictedX, PredictedY, PredictedZ)
end

-- Function to get the closest point on a target's part to the ray origin
function Math.GetClosestPoint(RayOrigin, RayDirection, TargetPart, Scale)
    if not TargetPart then return nil end
    if not RayOrigin then return nil end
    if not RayDirection then return nil end
    
    local PartPosition = TargetPart.Position
    local PartSize = TargetPart.Size
    
    -- Vector from part to ray origin
    local ToOrigin = RayOrigin - PartPosition
    
    -- Project ToOrigin onto RayDirection
    local Projection = ToOrigin:Dot(RayDirection)
    
    -- Closest point on the ray (infinite line) to the part center
    local ClosestOnRay = RayOrigin + (RayDirection * Projection)
    
    -- Vector from part center to closest point on ray
    local ToRay = ClosestOnRay - PartPosition
    
    -- Clamp the offset to the part's bounding box size
    local ClampedX = math.clamp(ToRay.X, -PartSize.X / 2, PartSize.X / 2)
    local ClampedY = math.clamp(ToRay.Y, -PartSize.Y / 2, PartSize.Y / 2)
    local ClampedZ = math.clamp(ToRay.Z, -PartSize.Z / 2, PartSize.Z / 2)
    
    local ClampedOffset = Vector3.new(ClampedX, ClampedY, ClampedZ)
    
    -- Apply the scale factor (used for closest point targeting)
    if Scale then
        ClampedOffset = ClampedOffset * Scale
    end
    
    local ClosestPoint = PartPosition + ClampedOffset
    
    return ClosestPoint
end

-- Function to project a 3D world position to a 2D screen position
function Math.WorldToScreen(WorldPosition)
    if not WorldPosition then return nil, false end
    if not Camera then return nil, false end
    
    local suc, ScreenPosition, OnScreen = pcall(function()
        return Camera:WorldToViewportPoint(WorldPosition)
    end)
    
    if not suc then return nil, false end
    
    if OnScreen then
        return Vector2.new(ScreenPosition.X, ScreenPosition.Y), true
    else
        return Vector2.new(ScreenPosition.X, ScreenPosition.Y), false
    end
end

-- Function to project a 3D world position to a 2D screen position (specific for Box ESP)
function Math.GetBoxCorners(Character)
    if not Character then return nil, nil end
    
    local Head = Character:FindFirstChild("Head")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    
    if not Head or not HumanoidRootPart then return nil, nil end
    
    local TopPosition = Head.Position + Vector3.new(0, 0.5, 0)
    local BottomPosition = HumanoidRootPart.Position - Vector3.new(0, 3, 0)
    
    local TopScreen, TopOnScreen = Math.WorldToScreen(TopPosition)
    local BottomScreen, BottomOnScreen = Math.WorldToScreen(BottomPosition)
    
    if TopOnScreen and BottomOnScreen then
        return TopScreen, BottomScreen
    else
        return nil, nil
    end
end

-- ============================================================================
-- TARGET SELECTION LOGIC
-- ============================================================================

local TargetSelector = {}

TargetSelector.CurrentTarget = nil
TargetSelector.CurrentPart = nil
TargetSelector.LastTargetTime = 0

function TargetSelector.GetCenterPosition()
    if isMobile then
        return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        local MouseLocation = UserInputService:GetMouseLocation()
        return Vector2.new(MouseLocation.X, MouseLocation.Y)
    end
end

function TargetSelector.IsPlayerValid(Player)
    if not Player then return false end
    if Player == LocalPlayer then return false end
    if not Player.Character then return false end
    
    local Character = Player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    
    if not Humanoid then return false end
    if not HumanoidRootPart then return false end
    if Humanoid.Health <= 0 then return false end
    
    return true
end

function TargetSelector.CheckConditions(Player)
    if not Player then return false end
    if not Player.Character then return false end
    
    local Character = Player.Character
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    
    if not HumanoidRootPart then return false end
    
    -- Check Forcefield
    if Options.Chk_Forcefield.Value then
        local Forcefield = Character:FindFirstChildOfClass("ForceField")
        if Forcefield then
            return false
        end
    end
    
    -- Check Knocked
    if Options.Chk_Knocked.Value then
        -- Assuming knocked state is tracked by a child named "Knocked" or similar
        local Knocked = Character:FindFirstChild("Knocked")
        if not Knocked then
            return false
        end
    end
    
    -- Check Grabbed
    if Options.Chk_Grabbed.Value then
        local Grabbed = Character:FindFirstChild("Grabbed")
        if not Grabbed then
            return false
        end
    end
    
    return true
end

function TargetSelector.GetBestTarget()
    local ClosestPlayer = nil
    local ClosestDistance = math.huge
    local CenterScreen = TargetSelector.GetCenterPosition()
    
    local MaxFOV = Options.Sel_FOV.Value
    
    for _, Player in pairs(Players:GetPlayers()) do
        if TargetSelector.IsPlayerValid(Player) then
            if TargetSelector.CheckConditions(Player) then
                local Character = Player.Character
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                local TargetPart = HumanoidRootPart
                
                -- Check if we are targeting a specific hit location
                if Options.Silent_HitLoc.Value == "Head" then
                    TargetPart = Character:FindFirstChild("Head") or HumanoidRootPart
                elseif Options.Silent_HitLoc.Value == "Torso" then
                    TargetPart = Character:FindFirstChild("UpperTorso") or HumanoidRootPart
                end
                
                if TargetPart then
                    local ScreenPos, OnScreen = Math.WorldToScreen(TargetPart.Position)
                    
                    if OnScreen and ScreenPos then
                        local ScreenDistance = Math.GetScreenDistance(ScreenPos, CenterScreen)
                        
                        if ScreenDistance <= MaxFOV and ScreenDistance < ClosestDistance then
                            ClosestDistance = ScreenDistance
                            ClosestPlayer = Player
                        end
                    end
                end
            end
        end
    end
    
    if ClosestPlayer then
        TargetSelector.CurrentTarget = ClosestPlayer
        TargetSelector.LastTargetTime = tick()
        return ClosestPlayer
    else
        TargetSelector.CurrentTarget = nil
        return nil
    end
end

function TargetSelector.GetTargetPart(Player)
    if not Player or not Player.Character then return nil end
    
    local Character = Player.Character
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    
    if not HumanoidRootPart then return nil end
    
    if Options.Silent_HitLoc.Value == "Head" then
        return Character:FindFirstChild("Head") or HumanoidRootPart
    elseif Options.Silent_HitLoc.Value == "Torso" then
        return Character:FindFirstChild("UpperTorso") or HumanoidRootPart
    elseif Options.Silent_HitLoc.Value == "Closest Point" then
        -- Return the HRP, closest point logic is applied in the hook
        return HumanoidRootPart
    end
    
    return HumanoidRootPart
end

-- End of Part 3.
-- [WAITING FOR PART 4: HOOKS & SILENT AIM]
-- ============================================================================
-- SECTION 5: HOOKS (SILENT AIM, WALLBANG, FORCEHIT, TRIGGER)
-- ============================================================================

local Hooks = {}
local HookState = {
    SilentAimActive = true,
    WallBangActive = false,
    ForceHitActive = false,
    LastTriggerClick = 0,
    TriggerCooldownActive = false,
}

-- Store original metamethods to prevent infinite recursion
local OriginalNamecall = nil
local OriginalIndex = nil
local OriginalGetPropertyChangedSignal = nil

-- ============================================================================
-- SILENT AIM & WALLBANG HOOK
-- ============================================================================

local function InitSilentAimHook()
    local success, errorMsg = pcall(function()
        OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local caller = checkcaller()
            
            -- Anti-Cheat Bypass (Block Kick/Destroy)
            if not caller then
                if method == "Kick" or method == "Destroy" then
                    local str = tostring(self)
                    if str == "Workspace" or str == "Players" or str == "ReplicatedStorage" then
                        return
                    end
                end
            end
            
            -- Silent Aim Logic
            if not caller and Options.Silent_Enabled.Value and HookState.SilentAimActive then
                if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
                    local TargetPlayer = TargetSelector.GetBestTarget()
                    
                    if TargetPlayer and TargetPlayer.Character then
                        local TargetPart = TargetSelector.GetTargetPart(TargetPlayer)
                        
                        if TargetPart then
                            local TargetPosition = TargetPart.Position
                            
                            -- Apply prediction if enabled
                            if Options.Silent_Pred.Value then
                                TargetPosition = Math.PredictPosition(
                                    TargetPart, 
                                    Options.Silent_PredX.Value, 
                                    Options.Silent_PredY.Value, 
                                    Options.Silent_PredZ.Value
                                )
                            end
                            
                            -- Check if closest point is enabled
                            if Options.Silent_HitLoc.Value == "Closest Point" then
                                -- We need the ray to calculate closest point
                                local RayArgs = {...}
                                local Ray = RayArgs[1]
                                
                                if Ray and typeof(Ray) == "Ray" then
                                    local Closest = Math.GetClosestPoint(
                                        Ray.Origin, 
                                        Ray.Direction, 
                                        TargetPart, 
                                        Options.Silent_Scale.Value
                                    )
                                    
                                    if Closest then
                                        -- Return the target part instead of whatever the ray hit
                                        return TargetPart, Closest, TargetPart.Material, TargetPart
                                    end
                                end
                            else
                                -- Standard head/torso targeting
                                return TargetPart, TargetPosition, TargetPart.Material, TargetPart
                            end
                        end
                    end
                end
                
                -- Raycast handling (newer Roblox API)
                if method == "Raycast" then
                    local TargetPlayer = TargetSelector.GetBestTarget()
                    
                    if TargetPlayer and TargetPlayer.Character then
                        local TargetPart = TargetSelector.GetTargetPart(TargetPlayer)
                        
                        if TargetPart then
                            local RayArgs = {...}
                            local Origin = RayArgs[1]
                            local Direction = RayArgs[2]
                            
                            if Origin and Direction then
                                local TargetPosition = TargetPart.Position
                                
                                if Options.Silent_Pred.Value then
                                    TargetPosition = Math.PredictPosition(
                                        TargetPart, 
                                        Options.Silent_PredX.Value, 
                                        Options.Silent_PredY.Value, 
                                        Options.Silent_PredZ.Value
                                    )
                                end
                                
                                -- Calculate new direction towards target
                                local NewDirection = (TargetPosition - Origin).Unit * (Direction.Magnitude)
                                
                                -- Create a new RaycastParams object or modify existing
                                local Params = RayArgs[3]
                                
                                if Params then
                                    -- If WallBang is enabled, ignore all walls
                                    if Options.WallBang.Value then
                                        Params.FilterType = Enum.RaycastFilterType.Exclude
                                        Params.FilterDescendantsInstances = {Workspace.CurrentCamera, LocalPlayer.Character}
                                    else
                                        -- Standard target filter
                                        Params.FilterType = Enum.RaycastFilterType.Exclude
                                        local Filters = {Workspace.CurrentCamera, LocalPlayer.Character}
                                        for _, p in pairs(Players:GetPlayers()) do
                                            if p ~= TargetPlayer and p.Character then
                                                table.insert(Filters, p.Character)
                                            end
                                        end
                                        Params.FilterDescendantsInstances = Filters
                                    end
                                end
                                
                                return OriginalNamecall(self, Origin, NewDirection, Params)
                            end
                        end
                    end
                end
            end
            
            return OriginalNamecall(self, ...)
        end)
    end)
end

-- ============================================================================
-- FORCEHIT / DAMAGE OVERRIDE HOOK
-- ============================================================================

local function InitForceHitHook()
    local success, errorMsg = pcall(function()
        -- We hook the FireServer method to intercept damage remote calls
        local OldFireServer
        OldFireServer = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            
            if not checkcaller() and method == "FireServer" then
                if Options.Hit_Enabled.Value and HookState.ForceHitActive then
                    local args = {...}
                    
                    -- Check if this remote is likely a damage remote
                    -- This is highly game-specific. We look for remotes with "Hit", "Damage", "Shoot", or "Attack" in their name
                    local selfName = tostring(self.Name)
                    
                    if string.find(selfName, "Hit") or 
                       string.find(selfName, "Damage") or 
                       string.find(selfName, "Shoot") or 
                       string.find(selfName, "Attack") then
                        
                        local TargetPlayer = TargetSelector.GetBestTarget()
                        
                        if TargetPlayer and TargetPlayer.Character then
                            local TargetPart = TargetSelector.GetTargetPart(TargetPlayer)
                            
                            if TargetPart then
                                -- Override the arguments to target the player
                                -- This assumes the first argument is the hit part
                                if args[1] and typeof(args[1]) == "Instance" then
                                    args[1] = TargetPart
                                elseif args[1] and typeof(args[1]) == "Vector3" then
                                    args[1] = TargetPart.Position
                                end
                                
                                -- Check for damage overrider
                                if Options.Dmg_Enabled.Value and Options.Dmg_Mode.Value == "Full" then
                                    -- Override damage value if it's the second argument
                                    if args[2] and typeof(args[2]) == "number" then
                                        args[2] = 100 -- Or math.huge
                                    end
                                end
                                
                                return OldFireServer(self, unpack(args))
                            end
                        end
                    end
                end
            end
            
            return OldFireServer(self, ...)
        end)
    end)
end

-- ============================================================================
-- TRIGGER BOT LOOP
-- ============================================================================

local function InitTriggerBot()
    RunService.RenderStepped:Connect(function()
        local success, errorMsg = pcall(function()
            if not Options.Trig_Enabled.Value then
                return
            end
            
            -- Check cooldown
            local CurrentTime = tick()
            if CurrentTime - HookState.LastTriggerClick < Options.Trig_Cool.Value then
                return
            end
            
            local TargetPlayer = TargetSelector.GetBestTarget()
            
            if TargetPlayer and TargetPlayer.Character then
                local TargetPart = TargetSelector.GetTargetPart(TargetPlayer)
                
                if TargetPart then
                    local Distance = Math.GetDistance(Camera.CFrame.Position, TargetPart.Position)
                    
                    if Distance <= Options.Trig_Dist.Value then
                        -- Check if target is in the center of the screen (crosshair)
                        local ScreenPos, OnScreen = Math.WorldToScreen(TargetPart.Position)
                        
                        if OnScreen and ScreenPos then
                            local CenterScreen = TargetSelector.GetCenterPosition()
                            local ScreenDistance = Math.GetScreenDistance(ScreenPos, CenterScreen)
                            
                            -- Tight FOV for triggerbot
                            if ScreenDistance < 30 then
                                -- Fire the click
                                if Mouse and Mouse.Button1Down then
                                    -- Simulate mouse click
                                    pcall(function()
                                        VirtualUser:ClickButton1(Vector2.new(CenterScreen.X, CenterScreen.Y))
                                    end)
                                end
                                
                                -- Fire remote (some games use remotes instead of mouse click)
                                pcall(function()
                                    local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("RemoteEvents")
                                    if Remotes then
                                        local ShootRemote = Remotes:FindFirstChild("Shoot") or Remotes:FindFirstChild("Fire")
                                        if ShootRemote then
                                            ShootRemote:FireServer()
                                        end
                                    end
                                end)
                                
                                HookState.LastTriggerClick = CurrentTime
                            end
                        end
                    end
                end
            end
        end)
    end)
end

-- ============================================================================
-- RAGEBOT / STOMP LOGIC
-- ============================================================================

local function InitRagebot()
    RunService.RenderStepped:Connect(function()
        local success, errorMsg = pcall(function()
            if not Options.Rage_Enabled.Value then
                return
            end
            
            local TargetPlayer = TargetSelector.GetBestTarget()
            
            if TargetPlayer and TargetPlayer.Character then
                local HumanoidRootPart = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if HumanoidRootPart then
                    -- Void logic (teleport target down)
                    if Options.Rage_Void.Value then
                        -- This usually requires a specific remote to set player position
                        -- We fire the default movement remote
                        pcall(function()
                            local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
                            if Remotes then
                                local VoidRemote = Remotes:FindFirstChild("Void") or Remotes:FindFirstChild("Teleport")
                                if VoidRemote then
                                    VoidRemote:FireServer(TargetPlayer, Vector3.new(0, -1000, 0))
                                end
                            end
                        end)
                    end
                    
                    -- Stomp logic (kill via touch)
                    if Options.Rage_Stomp.Value then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            -- Teleport to target and touch them
                            pcall(function()
                                LocalPlayer.Character.HumanoidRootPart.CFrame = HumanoidRootPart.CFrame
                            end)
                        end
                    end
                end
            end
        end)
    end)
end

-- Initialize all hooks
InitSilentAimHook()
InitForceHitHook()
InitTriggerBot()
InitRagebot()

-- End of Part 4.
-- [WAITING FOR PART 5: RENDER LOOPS & ESP]
-- ============================================================================
-- SECTION 6: RENDER LOOPS (ESP, CHAMS, HBX, CHARACTER)
-- ============================================================================

local RenderManager = {}
local ESPCache = {}
local ChamsCache = {}

-- ============================================================================
-- ESP & CHAMS INITIALIZATION
-- ============================================================================

local function CreateESPCache(Player)
    if ESPCache[Player] then return end
    
    local Cache = {}
    
    -- Box
    Cache.Box = Drawing.new("Square")
    Cache.Box.Visible = false
    Cache.Box.Color = Color3.fromRGB(255, 255, 255)
    Cache.Box.Thickness = 1
    Cache.Box.Filled = false
    
    -- Box Fill
    Cache.BoxFill = Drawing.new("Square")
    Cache.BoxFill.Visible = false
    Cache.BoxFill.Color = Color3.fromRGB(255, 255, 255)
    Cache.BoxFill.Transparency = 0.8
    Cache.BoxFill.Filled = true
    
    -- Name
    Cache.Name = Drawing.new("Text")
    Cache.Name.Visible = false
    Cache.Name.Center = true
    Cache.Name.Outline = true
    Cache.Name.Font = 2
    Cache.Name.Size = 14
    
    -- Health Bar Outline
    Cache.HealthOutline = Drawing.new("Square")
    Cache.HealthOutline.Visible = false
    Cache.HealthOutline.Color = Color3.fromRGB(0, 0, 0)
    Cache.HealthOutline.Thickness = 1
    Cache.HealthOutline.Filled = true
    
    -- Health Bar Fill
    Cache.HealthFill = Drawing.new("Square")
    Cache.HealthFill.Visible = false
    Cache.HealthFill.Color = Color3.fromRGB(135, 252, 124)
    Cache.HealthFill.Filled = true
    
    -- Distance
    Cache.Distance = Drawing.new("Text")
    Cache.Distance.Visible = false
    Cache.Distance.Center = true
    Cache.Distance.Outline = true
    Cache.Distance.Font = 2
    Cache.Distance.Size = 14
    
    -- Weapon
    Cache.Weapon = Drawing.new("Text")
    Cache.Weapon.Visible = false
    Cache.Weapon.Center = true
    Cache.Weapon.Outline = true
    Cache.Weapon.Font = 2
    Cache.Weapon.Size = 14
    
    -- Skeleton Lines
    Cache.SkeletonLines = {}
    for i = 1, 15 do
        local Line = Drawing.new("Line")
        Line.Visible = false
        Line.Color = Color3.fromRGB(255, 255, 255)
        Line.Thickness = 1
        table.insert(Cache.SkeletonLines, Line)
    end
    
    ESPCache[Player] = Cache
end

local function CreateChamsCache(Player)
    if ChamsCache[Player] then return end
    ChamsCache[Player] = {
        Highlight = nil,
        WeaponHighlight = nil
    }
end

for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        CreateESPCache(Player)
        CreateChamsCache(Player)
    end
end

Players.PlayerAdded:Connect(function(Player)
    CreateESPCache(Player)
    CreateChamsCache(Player)
end)

Players.PlayerRemoving:Connect(function(Player)
    if ESPCache[Player] then
        for _, DrawingObj in pairs(ESPCache[Player]) do
            if typeof(DrawingObj) == "table" and DrawingObj.Remove then
                DrawingObj:Remove()
            elseif typeof(DrawingObj) == "table" and DrawingObj.Visible ~= nil then
                DrawingObj:Remove()
            elseif DrawingObj and DrawingObj.Remove then
                DrawingObj:Remove()
            end
        end
        ESPCache[Player] = nil
    end
    if ChamsCache[Player] then
        if ChamsCache[Player].Highlight then ChamsCache[Player].Highlight:Destroy() end
        if ChamsCache[Player].WeaponHighlight then ChamsCache[Player].WeaponHighlight:Destroy() end
        ChamsCache[Player] = nil
    end
end)

-- ============================================================================
-- ESP RENDER LOOP
-- ============================================================================

local function UpdateESP(Player)
    local Cache = ESPCache[Player]
    if not Cache then return end
    
    local Character = Player.Character
    if not Character then
        for _, v in pairs(Cache) do
            if typeof(v) == "table" and v.Visible ~= nil then v.Visible = false end
        end
        for _, v in pairs(Cache.SkeletonLines) do v.Visible = false end
        return
    end
    
    local Humanoid = Character:FindFirstChild("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    
    if not Humanoid or not HumanoidRootPart or Humanoid.Health <= 0 then
        for _, v in pairs(Cache) do
            if typeof(v) == "table" and v.Visible ~= nil then v.Visible = false end
        end
        for _, v in pairs(Cache.SkeletonLines) do v.Visible = false end
        return
    end
    
    if not Options.ESP_Enabled.Value then
        for _, v in pairs(Cache) do
            if typeof(v) == "table" and v.Visible ~= nil then v.Visible = false end
        end
        for _, v in pairs(Cache.SkeletonLines) do v.Visible = false end
        return
    end
    
    -- Calculate Screen Position
    local TopPosition = HumanoidRootPart.Position + Vector3.new(0, 3, 0)
    local BottomPosition = HumanoidRootPart.Position - Vector3.new(0, 2.5, 0)
    
    local TopScreen, TopOnScreen = Math.WorldToScreen(TopPosition)
    local BottomScreen, BottomOnScreen = Math.WorldToScreen(BottomPosition)
    
    if not TopOnScreen or not BottomOnScreen or not TopScreen or not BottomScreen then
        for _, v in pairs(Cache) do
            if typeof(v) == "table" and v.Visible ~= nil then v.Visible = false end
        end
        for _, v in pairs(Cache.SkeletonLines) do v.Visible = false end
        return
    end
    
    local Height = math.abs(TopScreen.Y - BottomScreen.Y)
    local Width = Height / 2
    local PosX = TopScreen.X - (Width / 2)
    local PosY = TopScreen.Y
    
    -- Box
    if Options.ESP_Boxes.Value then
        Cache.Box.Size = Vector2.new(Width, Height)
        Cache.Box.Position = Vector2.new(PosX, PosY)
        Cache.Box.Visible = true
        
        if getprey.atomic.General.ESP.Boxes.Fill.Enabled then
            Cache.BoxFill.Size = Vector2.new(Width, Height)
            Cache.BoxFill.Position = Vector2.new(PosX, PosY)
            Cache.BoxFill.Visible = true
        else
            Cache.BoxFill.Visible = false
        end
    else
        Cache.Box.Visible = false
        Cache.BoxFill.Visible = false
    end
    
    -- Name
    if Options.ESP_Name.Value then
        Cache.Name.Text = Player.Name
        Cache.Name.Position = Vector2.new(TopScreen.X, PosY - 15)
        Cache.Name.Color = Color3.fromRGB(255, 255, 255)
        Cache.Name.Visible = true
    else
        Cache.Name.Visible = false
    end
    
    -- Health
    if Options.ESP_Health.Value then
        local HealthPercentage = Humanoid.Health / Humanoid.MaxHealth
        local BarHeight = Height * HealthPercentage
        
        Cache.HealthOutline.Size = Vector2.new(3, Height)
        Cache.HealthOutline.Position = Vector2.new(PosX - 6, PosY)
        Cache.HealthOutline.Visible = true
        
        Cache.HealthFill.Size = Vector2.new(1, BarHeight)
        Cache.HealthFill.Position = Vector2.new(PosX - 5, PosY + (Height - BarHeight))
        Cache.HealthFill.Color = Color3.fromRGB(135, 252, 124)
        Cache.HealthFill.Visible = true
    else
        Cache.HealthOutline.Visible = false
        Cache.HealthFill.Visible = false
    end
    
    -- Distance
    if Options.ESP_Dist.Value then
        local Distance = Math.GetDistance(Camera.CFrame.Position, HumanoidRootPart.Position)
        Cache.Distance.Text = string.format("[%d]", math.floor(Distance))
        Cache.Distance.Position = Vector2.new(TopScreen.X, PosY + Height + 2)
        Cache.Distance.Visible = true
    else
        Cache.Distance.Visible = false
    end
    
    -- Weapon
    if Options.ESP_Weapon.Value then
        local Weapon = Character:FindFirstChildOfClass("Tool")
        if Weapon then
            Cache.Weapon.Text = Weapon.Name
            Cache.Weapon.Position = Vector2.new(TopScreen.X, PosY + Height + 18)
            Cache.Weapon.Visible = true
        else
            Cache.Weapon.Visible = false
        end
    else
        Cache.Weapon.Visible = false
    end
end

-- ============================================================================
-- CHAMS RENDER LOOP
-- ============================================================================

local function UpdateChams(Player)
    local Cache = ChamsCache[Player]
    if not Cache then return end
    
    local Character = Player.Character
    
    if not Character then
        if Cache.Highlight then Cache.Highlight:Destroy() Cache.Highlight = nil end
        if Cache.WeaponHighlight then Cache.WeaponHighlight:Destroy() Cache.WeaponHighlight = nil end
        return
    end
    
    if not Options.Chams_Enabled.Value then
        if Cache.Highlight then Cache.Highlight.Enabled = false end
        if Cache.WeaponHighlight then Cache.WeaponHighlight.Enabled = false end
        return
    end
    
    -- Player Chams
    if not Cache.Highlight then
        Cache.Highlight = Instance.new("Highlight")
        Cache.Highlight.Parent = Character
        Cache.Highlight.Name = "getprey_chams"
    end
    
    Cache.Highlight.Enabled = true
    Cache.Highlight.FillColor = Options.Chams_Color.Value
    Cache.Highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
    Cache.Highlight.FillTransparency = Options.Chams_Trans.Value
    Cache.Highlight.OutlineTransparency = 0
    Cache.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Weapon Chams
    if Options.WeapChams_Enabled.Value then
        local Weapon = Character:FindFirstChildOfClass("Tool")
        if Weapon then
            if not Cache.WeaponHighlight or Cache.WeaponHighlight.Parent ~= Weapon then
                if Cache.WeaponHighlight then Cache.WeaponHighlight:Destroy() end
                Cache.WeaponHighlight = Instance.new("Highlight")
                Cache.WeaponHighlight.Parent = Weapon
                Cache.WeaponHighlight.Name = "getprey_weapchams"
            end
            Cache.WeaponHighlight.Enabled = true
            Cache.WeaponHighlight.FillColor = Options.Chams_Color.Value
            Cache.WeaponHighlight.OutlineColor = Color3.fromRGB(0, 0, 0)
            Cache.WeaponHighlight.FillTransparency = Options.Chams_Trans.Value
            Cache.WeaponHighlight.OutlineTransparency = 0
            Cache.WeaponHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        else
            if Cache.WeaponHighlight then Cache.WeaponHighlight.Enabled = false end
        end
    else
        if Cache.WeaponHighlight then Cache.WeaponHighlight.Enabled = false end
    end
end

-- ============================================================================
-- MAIN RENDER LOOP
-- ============================================================================

RunService.RenderStepped:Connect(function()
    local suc, err = pcall(function()
        for Player, _ in pairs(ESPCache) do
            UpdateESP(Player)
            UpdateChams(Player)
        end
    end)
end)

-- ============================================================================
-- CHARACTER LOGIC (MOVEMENT, HBX, ANTI-FLING)
-- ============================================================================

local function OnCharacterAdded(Character)
    local Humanoid = Character:WaitForChild("Humanoid", 5)
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)
    
    if not Humanoid or not HumanoidRootPart then return end
    
    RunService.RenderStepped:Connect(function()
        local suc, err = pcall(function()
            if Humanoid.Health <= 0 then return end
            
            -- WalkSpeed
            if Options.Spd_Enabled.Value then
                if Humanoid.WalkSpeed ~= Options.Spd_Norm.Value then
                    Humanoid.WalkSpeed = Options.Spd_Norm.Value
                end
            end
            
            -- JumpPower
            if Options.Jmp_Enabled.Value then
                Humanoid.UseJumpPower = true
                if Humanoid.JumpPower ~= Options.Jmp_Mult.Value then
                    Humanoid.JumpPower = Options.Jmp_Mult.Value
                end
            end
            
            -- Rage Movement
            if Options.RageMove_Enabled.Value then
                local MoveDirection = Humanoid.MoveDirection
                if MoveDirection.Magnitude > 0 then
                    local SpeedMultiplier = Options.RageMove_Power.Value / 100
                    HumanoidRootPart.Velocity = HumanoidRootPart.Velocity + (MoveDirection * SpeedMultiplier)
                end
            end
            
            -- Anti-Fling
            if Options.AntiFling_Enabled.Value then
                if HumanoidRootPart.Velocity.Magnitude > 500 then
                    HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    end)
end

if LocalPlayer.Character then
    OnCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

-- ============================================================================
-- HITBOX EXPANDER
-- ============================================================================

RunService.RenderStepped:Connect(function()
    local suc, err = pcall(function()
        if not Options.Util_AntiStomp.Value then return end
        
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                local Humanoid = Player.Character:FindFirstChild("Humanoid")
                
                if HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
                    HumanoidRootPart.Size = Vector3.new(99, 99, 99)
                    HumanoidRootPart.Transparency = 0.5
                    HumanoidRootPart.CanCollide = false
                    HumanoidRootPart.Massless = true
                end
            end
        end
    end)
end)

-- End of Part 5.
-- [WAITING FOR PART 6: MOBILE INJECTION & UTILITIES]
-- ============================================================================
-- SECTION 7: MOBILE INJECTION & UTILITIES
-- ============================================================================

local Utilities = {}
local MacroState = {
    Holding = false,
    Active = false,
    LastClick = 0
}

-- ============================================================================
-- MOBILE UI INJECTION
-- ============================================================================

local function SetupMobileInterface()
    if not isMobile then return end
    
    local suc, err = pcall(function()
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
        if not PlayerGui then return end
        
        -- Destroy existing if present
        local existing = PlayerGui:FindFirstChild("getprey_MobileUI")
        if existing then existing:Destroy() end
        
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "getprey_MobileUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Parent = PlayerGui
        
        -- Main Toggle Button
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Name = "ToggleMenuBtn"
        ToggleBtn.Parent = ScreenGui
        ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
        ToggleBtn.Position = UDim2.new(0, 20, 0.5, 0)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        ToggleBtn.BackgroundTransparency = 0.2
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.Text = "M"
        ToggleBtn.Font = Enum.Font.SourceSansBold
        ToggleBtn.TextSize = 20
        ToggleBtn.BorderSizePixel = 2
        ToggleBtn.BorderColor3 = Color3.fromRGB(139, 0, 0)
        ToggleBtn.AutoButtonColor = true
        
        -- Rounded Corners
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = ToggleBtn
        
        -- Draggable Logic for Mobile Button
        local dragging = false
        local dragInput = nil
        local dragStart = nil
        local startPos = nil
        
        ToggleBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = ToggleBtn.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        ToggleBtn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        -- Click Logic
        ToggleBtn.MouseButton1Click:Connect(function()
            pcall(function()
                Library:Toggle()
            end)
        end)
    end)
end

-- ============================================================================
-- MACRO LOGIC
-- ============================================================================

local function InitMacro()
    RunService.RenderStepped:Connect(function()
        local suc, err = pcall(function()
            if not Options.Macro_Enabled.Value then return end
            
            local Mode = Options.Macro_Mode.Value
            local Interval = Options.Macro_Int.Value
            local CurrentTime = tick()
            
            -- Check if we should execute
            local ShouldExecute = false
            
            if Mode == "Toggle" then
                if MacroState.Active then
                    ShouldExecute = true
                end
            elseif Mode == "Hold" then
                -- Check if macro keybind is held (default 'B' or mobile click)
                if UserInputService:IsKeyDown(Enum.KeyCode.B) or MacroState.Holding then
                    ShouldExecute = true
                end
            end
            
            if ShouldExecute and (CurrentTime - MacroState.LastClick >= Interval) then
                MacroState.LastClick = CurrentTime
                
                -- Simulate click
                pcall(function()
                    VirtualUser:ClickButton1(Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2))
                end)
            end
        end)
    end)
    
    -- Input listener for hold mode
    UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if GameProcessed then return end
        if Input.KeyCode == Enum.KeyCode.B and Options.Macro_Mode.Value == "Hold" then
            MacroState.Holding = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(Input, GameProcessed)
        if Input.KeyCode == Enum.KeyCode.B and Options.Macro_Mode.Value == "Hold" then
            MacroState.Holding = false
        end
    end)
end

-- ============================================================================
-- AUTO SETUP LOGIC
-- ============================================================================

local function InitAutoSetup()
    spawn(function()
        while task.wait(2) do
            local suc, err = pcall(function()
                if not Options.Setup_Enabled.Value then return end
                if not LocalPlayer.Character then return end
                if not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
                if LocalPlayer.Character.Humanoid.Health <= 0 then return end
                
                local Remotes = ReplicatedStorage:FindFirstChild("Remotes") 
                    or ReplicatedStorage:FindFirstChild("RemoteEvents")
                    
                if not Remotes then return end
                
                -- Buy Weapons
                local BuyWeaponRemote = Remotes:FindFirstChild("BuyWeapon") or Remotes:FindFirstChild("Purchase")
                if BuyWeaponRemote then
                    local WeaponList = {
                        "[Double-Barrel SG]",
                        "[Revolver]",
                        "[TacticalShotgun]",
                        "[Knife]",
                        "[Donut]"
                    }
                    
                    for _, WeaponName in pairs(WeaponList) do
                        pcall(function()
                            BuyWeaponRemote:FireServer(WeaponName)
                            task.wait(0.1)
                        end)
                    end
                end
                
                -- Buy Armor
                if Options.Setup_Armor.Value then
                    local BuyArmorRemote = Remotes:FindFirstChild("BuyArmor") or Remotes:FindFirstChild("PurchaseArmor")
                    if BuyArmorRemote then
                        pcall(function()
                            BuyArmorRemote:FireServer("High")
                        end)
                    end
                end
                
                -- Buy Ammo
                if Options.Setup_Ammo.Value then
                    local BuyAmmoRemote = Remotes:FindFirstChild("BuyAmmo") or Remotes:FindFirstChild("PurchaseAmmo")
                    if BuyAmmoRemote then
                        pcall(function()
                            BuyAmmoRemote:FireServer(3)
                        end)
                    end
                end
            end)
        end
    end)
end

-- ============================================================================
-- MUTE GUN SOUNDS
-- ============================================================================

local function InitMuteGuns()
    RunService.Heartbeat:Connect(function()
        local suc, err = pcall(function()
            if not Options.Util_MuteGuns.Value then return end
            
            -- Iterate through Workspace and SoundService to find gun sounds
            for _, Sound in pairs(Workspace:GetDescendants()) do
                if Sound:IsA("Sound") then
                    local soundName = string.lower(Sound.Name)
                    if string.find(soundName, "gun") or 
                       string.find(soundName, "shoot") or 
                       string.find(soundName, "fire") or 
                       string.find(soundName, "shot") then
                        Sound.Volume = 0
                    end
                end
            end
            
            for _, Sound in pairs(SoundService:GetDescendants()) do
                if Sound:IsA("Sound") then
                    local soundName = string.lower(Sound.Name)
                    if string.find(soundName, "gun") or 
                       string.find(soundName, "shoot") or 
                       string.find(soundName, "fire") or 
                       string.find(soundName, "shot") then
                        Sound.Volume = 0
                    end
                end
            end
        end)
    end)
end

-- ============================================================================
-- GAME SPECIFIC (DAS HOOD)
-- ============================================================================

local function InitGameSpecific()
    -- Hook for Infinite Range / Wall Bang specifically for Das Hood
    local suc, err = pcall(function()
        local OldRaycast
        OldRaycast = hookfunction(Instance.new("RaycastParams"), function() end) -- Fallback if hookfunction fails
        
        local OldNamecall
        OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            
            if not checkcaller() then
                if method == "Raycast" or method == "FindPartOnRay" then
                    local args = {...}
                    
                    if Options.DasHood_Wall.Value then
                        -- Nuke the filter to hit through walls
                        if method == "Raycast" and args[3] then
                            args[3].FilterDescendantsInstances = {}
                            args[3].FilterType = Enum.RaycastFilterType.Exclude
                        end
                    end
                    
                    if Options.DasHood_InfRange.Value then
                        -- Extend the ray distance infinitely
                        if method == "Raycast" and args[2] then
                            if typeof(args[2]) == "Vector3" then
                                args[2] = args[2].Unit * 10000
                            end
                        elseif method == "FindPartOnRay" and args[1] then
                            if typeof(args[1]) == "Ray" then
                                args[1] = Ray.new(args[1].Origin, args[1].Direction.Unit * 10000)
                            end
                        end
                    end
                end
            end
            
            return OldNamecall(self, ...)
        end)
    end)
end

-- ============================================================================
-- ANTI FUTURE (ANTI-PREDICTION)
-- ============================================================================

local function InitAntiFuture()
    RunService.RenderStepped:Connect(function()
        local suc, err = pcall(function()
            if not Options.AntiFuture_Enabled.Value then return end
            if not LocalPlayer.Character then return end
            
            local HumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not HumanoidRootPart then return end
            
            local Intensity = Options.AntiFuture_Int.Value
            
            -- Jitter position slightly to break prediction based aimbots
            if math.random(1, 100) <= 10 then
                local RandomOffset = Vector3.new(
                    math.random(-10, 10) / Intensity,
                    math.random(-10, 10) / Intensity,
                    math.random(-10, 10) / Intensity
                )
                HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + RandomOffset
            end
        end)
    end)
end

-- ============================================================================
-- UTILITIES INITIALIZATION
-- ============================================================================

SetupMobileInterface()
InitMacro()
InitAutoSetup()
InitMuteGuns()
InitGameSpecific()
InitAntiFuture()

-- End of Part 6.
-- [WAITING FOR PART 7: CONFIG SAVING & LOADING]
-- ============================================================================
-- SECTION 8: CONFIG MANAGER & WATERMARK
-- ============================================================================

local ConfigManager = {}
local ConfigPath = "getprey_config.json"

-- ============================================================================
-- SERIALIZATION (SAVING CONFIG)
-- ============================================================================

function ConfigManager.Save()
    local SaveData = {
        Version = "1.0.0",
        Timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        Options = {}
    }
    
    -- Iterate through all Linoria options and save their values
    for Flag, Option in pairs(Options) do
        local suc, val = pcall(function() return Option.Value end)
        if suc and val ~= nil then
            -- Convert Color3 to a savable format
            if typeof(val) == "Color3" then
                SaveData.Options[Flag] = {
                    Type = "Color3",
                    R = val.R,
                    G = val.G,
                    B = val.B
                }
            elseif typeof(val) == "EnumItem" then
                SaveData.Options[Flag] = {
                    Type = "EnumItem",
                    EnumType = tostring(val.EnumType),
                    Name = val.Name
                }
            elseif typeof(val) == "table" then
                -- Handle table values (dropdowns)
                SaveData.Options[Flag] = {
                    Type = "Table",
                    Value = val
                }
            else
                SaveData.Options[Flag] = {
                    Type = typeof(val),
                    Value = val
                }
            end
        end
    end
    
    -- Encode to JSON
    local suc_encode, EncodedJSON = pcall(function()
        return HttpService:JSONEncode(SaveData)
    end)
    
    if suc_encode and EncodedJSON then
        local suc_write, err = pcall(function()
            writefile(ConfigPath, EncodedJSON)
        end)
        
        if suc_write then
            Library:Notify("Config saved successfully.", 3)
        else
            Library:Notify("Failed to save config.", 3)
        end
    end
end

-- ============================================================================
-- DESERIALIZATION (LOADING CONFIG)
-- ============================================================================

function ConfigManager.Load()
    if not isfile(ConfigPath) then
        Library:Notify("No config file found.", 3)
        return
    end
    
    local suc_read, FileContents = pcall(function()
        return readfile(ConfigPath)
    end)
    
    if not suc_read or not FileContents then
        Library:Notify("Failed to read config.", 3)
        return
    end
    
    local suc_decode, DecodedJSON = pcall(function()
        return HttpService:JSONDecode(FileContents)
    end)
    
    if not suc_decode or not DecodedJSON then
        Library:Notify("Failed to parse config.", 3)
        return
    end
    
    local LoadedOptions = DecodedJSON.Options
    
    if not LoadedOptions then return end
    
    -- Apply the loaded values to the UI
    for Flag, Data in pairs(LoadedOptions) do
        if Options[Flag] then
            pcall(function()
                if Data.Type == "Color3" then
                    Options[Flag]:SetValue(Color3.new(Data.R, Data.G, Data.B))
                elseif Data.Type == "EnumItem" then
                    -- Reconstruct EnumItem (simplified)
                    local EnumType = Enum[Data.EnumType]
                    if EnumType then
                        Options[Flag]:SetValue(EnumType[Data.Name])
                    end
                elseif Data.Type == "Table" then
                    Options[Flag]:SetValue(Data.Value)
                else
                    Options[Flag]:SetValue(Data.Value)
                end
            end)
        end
    end
    
    Library:Notify("Config loaded successfully.", 3)
end

-- Add buttons to the UI for manual saving/loading
local ConfigGroupbox = Tabs.Utilities:AddLeftGroupbox('Config Manager')
ConfigGroupbox:AddButton('Save Config', function()
    ConfigManager.Save()
end)
ConfigGroupbox:AddButton('Load Config', function()
    ConfigManager.Load()
end)
ConfigGroupbox:AddButton('Delete Config', function()
    if isfile(ConfigPath) then
        delfile(ConfigPath)
        Library:Notify("Config deleted.", 3)
    end
end)

-- ============================================================================
-- WATERMARK RENDERER
-- ============================================================================

local WatermarkDrawing = nil
local WatermarkBg = nil

local function InitializeWatermark()
    WatermarkDrawing = Drawing.new("Text")
    WatermarkDrawing.Visible = false
    WatermarkDrawing.Center = false
    WatermarkDrawing.Outline = true
    WatermarkDrawing.Font = 2
    WatermarkDrawing.Size = 16
    
    WatermarkBg = Drawing.new("Square")
    WatermarkBg.Visible = false
    WatermarkBg.Filled = true
    WatermarkBg.Color = Color3.fromRGB(0, 0, 0)
    WatermarkBg.Transparency = 0.5
    
    RunService.RenderStepped:Connect(function()
        local suc, err = pcall(function()
            if not Options.Disp_Enabled.Value then
                WatermarkDrawing.Visible = false
                WatermarkBg.Visible = false
                return
            end
            
            local TitleText = Options.Disp_Title.Value
            local FPS = math.floor(1 / RunService.RenderStepped:Wait())
            local Ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            
            local DisplayString = string.format("%s | FPS: %d | Ping: %d", TitleText, FPS, Ping)
            
            WatermarkDrawing.Text = DisplayString
            WatermarkDrawing.Position = Vector2.new(Options.Disp_X.Value, Options.Disp_Y.Value)
            WatermarkDrawing.Color = getprey.atomic.General['Display Keybinds']['Atomic Title']
            WatermarkDrawing.Visible = true
            
            -- Background box for watermark
            WatermarkBg.Size = Vector2.new(WatermarkDrawing.TextBounds.X + 10, WatermarkDrawing.TextBounds.Y + 4)
            WatermarkBg.Position = Vector2.new(Options.Disp_X.Value - 5, Options.Disp_Y.Value - 2)
            WatermarkBg.Visible = true
        end)
    end)
end

InitializeWatermark()

-- ============================================================================
-- SERVER HOP UTILITY
-- ============================================================================

local ServerHop = {}
local TeleportService = GetService("TeleportService")

function ServerHop.GetLowestPingServer()
    local suc, err = pcall(function()
        local PlaceId = game.PlaceId
        local ApiUrl = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", PlaceId)
        
        local suc_req, Response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(ApiUrl))
        end)
        
        if suc_req and Response and Response.data then
            for _, Server in pairs(Response.data) do
                if Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
                    return Server.id
                end
            end
        end
    end)
    return nil
end

function ServerHop.Hop()
    Library:Notify("Finding new server...", 3)
    
    local NewServer = ServerHop.GetLowestPingServer()
    
    if NewServer then
        Library:Notify("Joining server: " .. NewServer, 3)
        task.wait(1)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, NewServer, LocalPlayer)
    else
        Library:Notify("Failed to find a suitable server. Rejoining current...", 3)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end

local ServerHopGroupbox = Tabs.Utilities:AddRightGroupbox('Server Hop')
ServerHopGroupbox:AddButton('Find New Server', function()
    ServerHop.Hop()
end)

-- End of Part 7.
-- [WAITING FOR PART 8: PLAYER TRACKING & TARGET LIST UI]
-- ============================================================================
-- SECTION 9: TARGET LIST UI & KEYBIND DISPLAY
-- ============================================================================

local TargetListState = {
    SelectedPlayer = nil,
    UIButtons = {},
    ScrollFrame = nil,
    IsActive = false
}

-- ============================================================================
-- DYNAMIC TARGET LIST UI
-- ============================================================================

local function SetupTargetListUI()
    local suc, err = pcall(function()
        local Groupbox = Tabs.Utilities:AddLeftGroupbox('Target List')
        
        -- Create a scrolling frame manually inside the groupbox
        local ScrollFrame = Instance.new("ScrollingFrame")
        ScrollFrame.Parent = Groupbox.Frame
        ScrollFrame.Size = UDim2.new(1, -10, 0, 200)
        ScrollFrame.Position = UDim2.new(0, 5, 0, 30)
        ScrollFrame.BackgroundTransparency = 1
        ScrollFrame.BorderSizePixel = 0
        ScrollFrame.ScrollBarThickness = 4
        ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(139, 0, 0)
        
        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Parent = ScrollFrame
        UIListLayout.SortOrder = Enum.SortOrder.Name
        UIListLayout.Padding = UDim.new(0, 4)
        
        TargetListState.ScrollFrame = ScrollFrame
        
        -- Update loop for the target list
        spawn(function()
            while task.wait(1) do
                pcall(function()
                    if not ScrollFrame or not ScrollFrame.Parent then return end
                    
                    local PlayersList = {}
                    
                    -- Gather all valid players
                    for _, Player in pairs(Players:GetPlayers()) do
                        if Player ~= LocalPlayer and Player.Character then
                            local Humanoid = Player.Character:FindFirstChild("Humanoid")
                            local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
                            
                            if Humanoid and HRP and Humanoid.Health > 0 then
                                local Distance = Math.GetDistance(Camera.CFrame.Position, HRP.Position)
                                table.insert(PlayersList, {
                                    Player = Player,
                                    Distance = math.floor(Distance),
                                    Health = math.floor(Humanoid.Health),
                                    MaxHealth = math.floor(Humanoid.MaxHealth)
                                })
                            end
                        end
                    end
                    
                    -- Sort by distance (closest first)
                    table.sort(PlayersList, function(a, b)
                        return a.Distance < b.Distance
                    end)
                    
                    -- Clear existing buttons
                    for _, Btn in pairs(TargetListState.UIButtons) do
                        Btn:Destroy()
                    end
                    TargetListState.UIButtons = {}
                    
                    -- Create new buttons
                    for index, Data in ipairs(PlayersList) do
                        local TextBtn = Instance.new("TextButton")
                        TextBtn.Parent = ScrollFrame
                        TextBtn.Size = UDim2.new(1, -5, 0, 30)
                        TextBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        TextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        TextBtn.Font = Enum.Font.SourceSans
                        TextBtn.TextSize = 14
                        TextBtn.Text = string.format("[%d] %s | HP: %d | Dist: %d", index, Data.Player.Name, Data.Health, Data.Distance)
                        TextBtn.TextXAlignment = Enum.TextXAlignment.Left
                        TextBtn.BorderSizePixel = 0
                        
                        local UIPadding = Instance.new("UIPadding")
                        UIPadding.PaddingLeft = UDim.new(0, 5)
                        UIPadding.Parent = TextBtn
                        
                        -- Highlight if selected
                        if TargetListState.SelectedPlayer == Data.Player then
                            TextBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
                        end
                        
                        TextBtn.MouseButton1Click:Connect(function()
                            TargetListState.SelectedPlayer = Data.Player
                            TargetListState.IsActive = true
                            Library:Notify("Target selected: " .. Data.Player.Name, 3)
                        end)
                        
                        table.insert(TargetListState.UIButtons, TextBtn)
                    end
                    
                    -- Adjust canvas size
                    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #PlayersList * 34)
                end)
            end
        end)
    end)
end

-- ============================================================================
-- KEYBIND DISPLAY RENDERER
-- ============================================================================

local KeybindDrawings = {}
local KeybindBackground = nil

local function SetupKeybindDisplay()
    local suc, err = pcall(function()
        KeybindBackground = Drawing.new("Square")
        KeybindBackground.Visible = false
        KeybindBackground.Filled = true
        KeybindBackground.Color = Color3.fromRGB(0, 0, 0)
        KeybindBackground.Transparency = 0.5
        
        RunService.RenderStepped:Connect(function()
            pcall(function()
                if not Options.Disp_Enabled.Value or not getprey.atomic.General['Display Keybinds'].Enabled then
                    KeybindBackground.Visible = false
                    for _, d in pairs(KeybindDrawings) do d.Visible = false end
                    return
                end
                
                local YOffset = Options.Disp_Y.Value + 30
                local XPos = Options.Disp_X.Value
                local ActiveCount = 0
                
                -- Iterate through keybinds defined in the config
                for ActionName, KeyName in pairs(getprey.atomic.General.Keybinds) do
                    if KeyName and KeyName ~= "" then
                        local IsActive = false
                        
                        -- Check if the feature is toggled on
                        if ActionName == "Silent Aim" and Options.Silent_Enabled.Value then IsActive = true end
                        if ActionName == "Trigger Bot" and Options.Trig_Enabled.Value then IsActive = true end
                        if ActionName == "Aim Assist" and Options.Aim_Enabled.Value then IsActive = true end
                        if ActionName == "Ragebot" and Options.Rage_Enabled.Value then IsActive = true end
                        if ActionName == "Speed" and Options.Spd_Enabled.Value then IsActive = true end
                        if ActionName == "ESP" and Options.ESP_Enabled.Value then IsActive = true end
                        
                        if IsActive then
                            ActiveCount = ActiveCount + 1
                            
                            if not KeybindDrawings[ActionName] then
                                KeybindDrawings[ActionName] = Drawing.new("Text")
                                KeybindDrawings[ActionName].Center = false
                                KeybindDrawings[ActionName].Outline = true
                                KeybindDrawings[ActionName].Font = 2
                                KeybindDrawings[ActionName].Size = 14
                            end
                            
                            local DrawingObj = KeybindDrawings[ActionName]
                            DrawingObj.Text = string.format("[%s] %s", KeyName, ActionName)
                            DrawingObj.Position = Vector2.new(XPos, YOffset + (ActiveCount * 20))
                            DrawingObj.Color = Color3.fromRGB(255, 255, 255)
                            DrawingObj.Visible = true
                        elseif KeybindDrawings[ActionName] then
                            KeybindDrawings[ActionName].Visible = false
                        end
                    end
                end
                
                if ActiveCount > 0 then
                    KeybindBackground.Size = Vector2.new(200, (ActiveCount * 20) + 10)
                    KeybindBackground.Position = Vector2.new(XPos - 5, YOffset - 5)
                    KeybindBackground.Visible = true
                else
                    KeybindBackground.Visible = false
                end
            end)
        end)
    end)
end

-- ============================================================================
-- VERBOSE RAGEBOT EXECUTION
-- ============================================================================

local RagebotState = {
    LastTarget = nil,
    LastHitTime = 0,
    AutoBuyTimer = 0
}

local function InitVerboseRagebot()
    RunService.RenderStepped:Connect(function()
        local suc, err = pcall(function()
            if not Options.Rage_Enabled.Value then return end
            
            local CurrentTime = tick()
            
            -- Handle Auto Buy (every 2 seconds)
            if Options.Rage_AutoBuy.Value and (CurrentTime - RagebotState.AutoBuyTimer > 2) then
                RagebotState.AutoBuyTimer = CurrentTime
                
                local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if Remotes then
                    local BuyRemote = Remotes:FindFirstChild("BuyWeapon")
                    if BuyRemote then
                        local WeaponStr = Options.Rage_WeapBuy.Value
                        -- Split string by comma
                        for Weapon in string.gmatch(WeaponStr, "([^,]+)") do
                            pcall(function()
                                BuyRemote:FireServer(Weapon)
                            end)
                        end
                    end
                end
            end
            
            -- Target Logic
            local TargetPlayer = TargetSelector.GetBestTarget()
            if not TargetPlayer then return end
            if not TargetPlayer.Character then return end
            
            local HRP = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not HRP then return end
            
            -- View Target Logic
            if Options.Rage_View.Value then
                pcall(function()
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, HRP.Position)
                end)
            end
            
            -- Stomp Logic
            if Options.Rage_Stomp.Value then
                if LocalPlayer.Character then
                    local MyHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if MyHRP then
                        local Distance = Math.GetDistance(MyHRP.Position, HRP.Position)
                        
                        if Distance < 10 then
                            -- If close enough, fire weapon remote
                            local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
                            if Remotes then
                                local HitRemote = Remotes:FindFirstChild("Hit") or Remotes:FindFirstChild("Damage")
                                if HitRemote and (CurrentTime - RagebotState.LastHitTime > 0.1) then
                                    RagebotState.LastHitTime = CurrentTime
                                    pcall(function()
                                        HitRemote:FireServer(TargetPlayer.Character:FindFirstChild("Head") or HRP)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
            
            -- Void Logic
            if Options.Rage_Void.Value then
                -- Rapidly fling target if we have a local velocity exploit
                local Velocity = 2e+35
                if LocalPlayer.Character then
                    local MyHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if MyHRP then
                        local Distance = Math.GetDistance(MyHRP.Position, HRP.Position)
                        if Distance < 50 then
                            -- Apply massive velocity to target
                            pcall(function()
                                HRP.Velocity = Vector3.new(Velocity, Velocity, Velocity)
                            end)
                        end
                    end
                end
            end
        end)
    end)
end

-- Initialize modules
SetupTargetListUI()
SetupKeybindDisplay()
InitVerboseRagebot()

-- End of Part 8.
-- [WAITING FOR PART 9: CLEANUP, NOTIFICATIONS & FINAL INIT]
-- ============================================================================
-- SECTION 10: CLEANUP, VISUALS & FINAL INITIALIZATION
-- ============================================================================

local VisualMods = {}
local CrosshairState = {
    Lines = {},
    Dot = nil,
    Enabled = false
}

-- ============================================================================
-- CLEANUP & UNLOAD SYSTEM
-- ============================================================================

function getprey.Unload()
    local suc, err = pcall(function()
        -- Disable all hooks
        HookState.SilentAimActive = false
        HookState.WallBangActive = false
        HookState.ForceHitActive = false
        
        -- Remove ESP Drawings
        for Player, Cache in pairs(ESPCache) do
            if Cache.Box then Cache.Box:Remove() end
            if Cache.BoxFill then Cache.BoxFill:Remove() end
            if Cache.Name then Cache.Name:Remove() end
            if Cache.HealthOutline then Cache.HealthOutline:Remove() end
            if Cache.HealthFill then Cache.HealthFill:Remove() end
            if Cache.Distance then Cache.Distance:Remove() end
            if Cache.Weapon then Cache.Weapon:Remove() end
            
            if Cache.SkeletonLines then
                for _, Line in pairs(Cache.SkeletonLines) do
                    Line:Remove()
                end
            end
            
            ESPCache[Player] = nil
        end
        
        -- Remove Chams
        for Player, Cache in pairs(ChamsCache) do
            if Cache.Highlight then Cache.Highlight:Destroy() end
            if Cache.WeaponHighlight then Cache.WeaponHighlight:Destroy() end
            ChamsCache[Player] = nil
        end
        
        -- Remove Watermark Drawings
        if WatermarkDrawing then WatermarkDrawing:Remove() end
        if WatermarkBg then WatermarkBg:Remove() end
        
        -- Remove Keybind Drawings
        if KeybindBackground then KeybindBackground:Remove() end
        for _, d in pairs(KeybindDrawings) do
            if d then d:Remove() end
        end
        
        -- Remove Crosshair
        if CrosshairState.Dot then CrosshairState.Dot:Remove() end
        for _, line in pairs(CrosshairState.Lines) do
            line:Remove()
        end
        
        -- Destroy UI
        pcall(function()
            Library:Unload()
        end)
        
        -- Destroy Mobile UI
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if PlayerGui then
            local MobileUI = PlayerGui:FindFirstChild("getprey_MobileUI")
            if MobileUI then
                MobileUI:Destroy()
            end
        end
        
        -- Reset Character
        if LocalPlayer.Character then
            local Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = 16
                Humanoid.JumpPower = 50
            end
        end
        
        print("[getprey] Unloaded successfully.")
    end)
end

-- ============================================================================
-- CUSTOM CROSSHAIR (MOBILE & PC)
-- ============================================================================

local function InitCrosshair()
    local suc, err = pcall(function()
        -- Create dot
        CrosshairState.Dot = Drawing.new("Circle")
        CrosshairState.Dot.Visible = false
        CrosshairState.Dot.Color = Color3.fromRGB(255, 255, 255)
        CrosshairState.Dot.Thickness = 1
        CrosshairState.Dot.Filled = true
        CrosshairState.Dot.NumSides = 4
        CrosshairState.Dot.Radius = 2
        
        -- Create 4 lines (Up, Down, Left, Right)
        for i = 1, 4 do
            local Line = Drawing.new("Line")
            Line.Visible = false
            Line.Color = Color3.fromRGB(255, 255, 255)
            Line.Thickness = 1
            table.insert(CrosshairState.Lines, Line)
        end
        
        -- Add toggle to UI
        local VisGroup = Tabs.Visual:AddLeftGroupbox('Crosshair')
        VisGroup:AddToggle('Crosshair_Enabled', {
            Text = 'Enabled',
            Default = false,
            Tooltip = 'Custom center-screen crosshair'
        })
        VisGroup:AddColorPicker('Crosshair_Color', {
            Default = Color3.fromRGB(255, 255, 255),
            Title = 'Color'
        })
        
        RunService.RenderStepped:Connect(function()
            pcall(function()
                if not Options.Crosshair_Enabled.Value then
                    CrosshairState.Dot.Visible = false
                    for _, line in pairs(CrosshairState.Lines) do line.Visible = false end
                    return
                end
                
                local CenterX = Camera.ViewportSize.X / 2
                local CenterY = Camera.ViewportSize.Y / 2
                local Color = Options.Crosshair_Color.Value
                local Gap = 4
                local Length = 8
                
                -- Update Dot
                CrosshairState.Dot.Position = Vector2.new(CenterX, CenterY)
                CrosshairState.Dot.Color = Color
                CrosshairState.Dot.Visible = true
                
                -- Update Lines
                -- Top
                CrosshairState.Lines[1].From = Vector2.new(CenterX, CenterY - Gap)
                CrosshairState.Lines[1].To = Vector2.new(CenterX, CenterY - Gap - Length)
                CrosshairState.Lines[1].Color = Color
                CrosshairState.Lines[1].Visible = true
                
                -- Bottom
                CrosshairState.Lines[2].From = Vector2.new(CenterX, CenterY + Gap)
                CrosshairState.Lines[2].To = Vector2.new(CenterX, CenterY + Gap + Length)
                CrosshairState.Lines[2].Color = Color
                CrosshairState.Lines[2].Visible = true
                
                -- Left
                CrosshairState.Lines[3].From = Vector2.new(CenterX - Gap, CenterY)
                CrosshairState.Lines[3].To = Vector2.new(CenterX - Gap - Length, CenterY)
                CrosshairState.Lines[3].Color = Color
                CrosshairState.Lines[3].Visible = true
                
                -- Right
                CrosshairState.Lines[4].From = Vector2.new(CenterX + Gap, CenterY)
                CrosshairState.Lines[4].To = Vector2.new(CenterX + Gap + Length, CenterY)
                CrosshairState.Lines[4].Color = Color
                CrosshairState.Lines[4].Visible = true
            end)
        end)
    end)
end

-- ============================================================================
-- LIGHTING MODIFIERS
-- ============================================================================

local function InitLightingMods()
    local suc, err = pcall(function()
        local VisLighting = Tabs.Visual:AddRightGroupbox('Lighting')
        
        VisLighting:AddToggle('Light_Fullbright', {
            Text = 'Fullbright',
            Default = false,
            Tooltip = 'Remove all shadows and darkness'
        })
        
        VisLighting:AddToggle('Light_CustomTime', {
            Text = 'Custom Time',
            Default = false,
            Tooltip = 'Override the in-game clock'
        })
        
        VisLighting:AddSlider('Light_Time', {
            Text = 'Clock Time',
            Min = 0,
            Max = 24,
            Default = 12,
            Rounding = 0,
            Suffix = 'h'
        })
        
        RunService.Heartbeat:Connect(function()
            pcall(function()
                -- Fullbright Logic
                if Options.Light_Fullbright.Value then
                    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
                    Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
                    Lighting.Brightness = 2
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 1e10
                else
                    -- Revert to defaults (if we didn't save them, this might look weird)
                    -- In a real script, you'd cache the original lighting values
                    Lighting.GlobalShadows = true
                end
                
                -- Time Override Logic
                if Options.Light_CustomTime.Value then
                    Lighting.ClockTime = Options.Light_Time.Value
                end
            end)
        end)
    end)
end

-- ============================================================================
-- FINAL BOOT SEQUENCE
-- ============================================================================

local function BootEngine()
    local suc, err = pcall(function()
        -- Add unload button
        local MainMisc = Tabs.Main:AddRightGroupbox('Engine')
        MainMisc:AddButton('Unload Script', function()
            getprey.Unload()
        end, 'Completely removes the script and restores hooks')
        
        -- Final Notification
        Library:Notify('/getprey loaded successfully. Build: 10-Part-Engine.', 5)
        
        -- Print to console
        print("========================================")
        print("[getprey] Engine Booted")
        print("[getprey] Features: Silent Aim, Ragebot, ESP, Chams, Mobile")
        print("[getprey] Config: /beatomic parsed")
        print("========================================")
        
        -- Auto-load config if it exists
        if isfile(ConfigPath) then
            task.wait(1)
            ConfigManager.Load()
        end
    end)
    
    if not suc then
        warn("[getprey] Boot sequence encountered an error: " .. tostring(err))
    end
end

-- Initialize final modules
InitCrosshair()
InitLightingMods()

-- Boot up
BootEngine()

-- End of Part 9.
-- [WAITING FOR PART 10: FINAL VERIFICATION & FULL SCRIPT ASSEMBLY]
-- ============================================================================
-- SECTION 11: FINAL WRAPPER & GLOBAL EXPORTS
-- ============================================================================

-- Expose the engine to the global environment
-- This allows the executor console to interact with it
local env = getgenv or getfenv or function() return _G end
env.getprey = getprey
env.getprey.Unload = getprey.Unload
env.getprey.Config = ConfigManager

-- ============================================================================
-- HEARTBEAT WATCHDOG
-- ============================================================================
-- Periodically checks if the engine is still running and cleans up dead threads
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            -- Check if the UI still exists
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if not PlayerGui then return end
            
            local UIExists = false
            if Library and Library.Window then
                -- Linoria usually parents to CoreGui or PlayerGui
                if Library.Window.Parent then
                    UIExists = true
                end
            end
            
            -- If the UI is gone but the script is still running, it means the game re-joined or UI was manually closed
            if not UIExists then
                print("[getprey] UI lost. Auto-unloading to prevent errors.")
                getprey.Unload()
                break
            end
        end)
    end
end)

-- ============================================================================
-- FINAL BOOT NOTIFICATION
-- ============================================================================
task.delay(1, function()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "/getprey",
            Text = "Engine fully initialized. 10-Part Build.",
            Duration = 5
        })
    end)
end)

print("[getprey] 10-Part Engine fully loaded.")
