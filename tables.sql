CREATE TYPE LOG_SUBTYPE_ENUM AS ENUM (
  'run', 
  'subsystem', 
  'announcement',
  'gas',
  'intervention',
  'issue',
  'comment'
);

CREATE TYPE LOG_ORIGIN_ENUM AS ENUM (
  'human',
  'process'
);

CREATE TYPE ENTRY_TYPE_ENUM AS ENUM (
  'general',
  'EOS',
  'DCS'
);

CREATE TYPE INTERVENTION_TYPE_ENUM AS ENUM (
  '?',
  '??',
  '???'
);

CREATE TYPE ISSUE_STATUS_ENUM AS ENUM (
  'open',
  'closed'
);

CREATE TABLE Users (
  user_id SERIAL PRIMARY KEY,
  sams_id INTEGER
);

INSERT INTO Users (user_id, sams_id) VALUES (0, NULL);

CREATE TABLE Runs (
  run_number SERIAL PRIMARY KEY
  /* TODO: lots of run info */
);

INSERT INTO Runs (run_number) VALUES (0);

/* TODO: Add not-nulls */
CREATE TABLE Logs (
  log_id SERIAL PRIMARY KEY,
  log_subtype LOG_SUBTYPE_ENUM,
  fk_user_id INTEGER NOT NULL references Users(user_id),
  origin LOG_ORIGIN_ENUM NOT NULL,
  entry_type ENTRY_TYPE_ENUM NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  title VARCHAR(255) NOT NULL,
  text VARCHAR(20000) NOT NULL,
  run_fk_run_number INTEGER references Runs(run_number),
  announcement_valid_until TIMESTAMP,
  intervention_type INTERVENTION_TYPE_ENUM,
  issue_status ISSUE_STATUS_ENUM,
  comment_fk_parent_log_id INTEGER DEFAULT NULL references Logs(log_id),
  comment_fk_root_log_id INTEGER DEFAULT NULL references Logs(log_id)
);