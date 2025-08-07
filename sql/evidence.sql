CREATE TABLE evidence (
    id VARCHAR(64) PRIMARY KEY,
    type VARCHAR(32),
    coords TEXT,
    collected_by VARCHAR(64),
    description TEXT,
    timestamp INT
);

CREATE TABLE witness_statements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    npc_id INT,
    case_id VARCHAR(64),
    statement TEXT,
    timestamp INT
);

CREATE TABLE calls (
    id VARCHAR(64) PRIMARY KEY,
    type VARCHAR(32),
    coords TEXT,
    details TEXT,
    timestamp INT
);

CREATE TABLE reputation (
    identifier VARCHAR(64) PRIMARY KEY,
    score INT DEFAULT 0
);