Config = {}

Config.Framework = "QBCore" -- or "ESX"
Config.PoliceJobs = { "police", "sheriff", "detective" }
Config.JudgeJobs = { "judge" }
Config.AdminJobs = { "admin" }
Config.EvidenceTypes = { "shell_casing", "blood_sample", "fingerprint", "weapon_fragment", "drug_residue" }

-- Evidence locations and types
Config.EvidenceLocations = {
    {x = 100.0, y = 200.0, z = 30.0, heading = 180.0, type = "vault"},
    {x = 50.0, y = 150.0, z = 28.0, heading = 90.0, type = "crimelab"}
}

Config.EvidenceTypes = {
    ["shellcasing"] = {label = "Bullet Casing", model = `w_ar_assaultrifle_lr`},
    ["bloodsample"] = {label = "Blood Sample", model = `prop_blood_splat_01`},
    ["fingerprint"] = {label = "Fingerprint", model = `prop_fingerprint_01`}
}

-- Witness statement generation settings
Config.WitnessStatementSettings = {
    minProximity = 10.0, -- Minimum distance for an NPC to be considered a witness
    lineOfSightRequired = true,
    statementTemplates = {
        "I saw some people doing something at around %s on %s.",
        "There was a loud noise and then I saw someone running.",
        "I was walking by when I heard shouting and saw some people fighting.",
        "I think I saw a %s but I'm not sure.",
        "They were wearing masks, so I couldn't see their faces clearly."
    },
    -- Add more templates and keywords here
}

-- Reputation system thresholds and rewards/penalties
Config.ReputationThresholds = {
    GoodCop = 500,
    BadCop = -500,
    -- Define other reputation thresholds
}

-- MDT and Dispatch System settings
Config.MDT = {
    enableEvidenceModule = true,
    enableWitnessModule = true,
    enableScenarioModule = true
}

-- Add other shared configurations here