CREATE TABLE IF NOT EXISTS `cases` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `case_id` VARCHAR(50) NOT NULL UNIQUE,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT,
    `created_by` VARCHAR(255) NOT NULL, -- ESX identifier or QBCore citizenid
    `created_at` INT(11) NOT NULL,
    `status` VARCHAR(50) DEFAULT 'open',
    PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `evidence` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `evidence_id` VARCHAR(50) NOT NULL UNIQUE,
    `type` VARCHAR(50) NOT NULL,
    `coords` TEXT NOT NULL, -- JSON string of coordinates
    `case_id` VARCHAR(50),
    `collected_by` VARCHAR(255) NOT NULL,
    `timestamp` INT(11) NOT NULL,
    `description` TEXT,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`case_id`) REFERENCES `cases`(`case_id`) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS `witnesses` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `crime_scene_id` VARCHAR(50) NOT NULL, -- Reference to the incident that generated the witness
    `coords` TEXT NOT NULL,
    `statement` TEXT NOT NULL,
    `npc_id` INT(11), -- Optional: If you want to track specific NPCs
    `timestamp` INT(11) NOT NULL,
    PRIMARY KEY (`id`)
);

-- Add tables for reputations, emergency callouts, etc. as needed