CREATE TABLE cases (
    id VARCHAR(64) PRIMARY KEY,
    title VARCHAR(128),
    description TEXT,
    status VARCHAR(32),
    created_by VARCHAR(64),
    created_at INT
);

CREATE TABLE evidence (
    id VARCHAR(64) PRIMARY KEY,
    type VARCHAR(32),
    coords TEXT,
    case_id VARCHAR(64),
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

CREATE TABLE scenarios (
    id VARCHAR(64) PRIMARY KEY,
    type VARCHAR(32),
    details TEXT,
    coords TEXT,
    case_id VARCHAR(64),
    timestamp INT
);

CREATE TABLE reputation (
    identifier VARCHAR(64) PRIMARY KEY,
    score INT DEFAULT 0
);