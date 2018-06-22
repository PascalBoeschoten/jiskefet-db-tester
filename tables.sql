BEGIN;

/* Custom datatypes */

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

CREATE TYPE RUN_TYPE_ENUM AS ENUM (
  'PHYSICS',
  'COSMICS',
  'TECHNICAL'
  );
  
CREATE TYPE RUN_QUALITY_ENUM AS ENUM (
  'GOOD',
  'BAD',
  'UNKNOWN'
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
  
  
/* User related stuff */

CREATE TABLE Users (
  user_id SERIAL PRIMARY KEY,
  sams_id INTEGER,
  token VARCHAR(32),
  token_valid_untill TIMESTAMP
  );
  
CREATE TABLE UserFilters (
  filter_id SERIAL,
  fk_user_id INTEGER REFERENCES Users(user_id),
  PRIMARY KEY (filter_id, fk_user_id)
  /* TODO: Add filter fields */
  );
    
CREATE TABLE UserNotifications (
  fk_user_id INTEGER PRIMARY KEY REFERENCES Users(user_id),
  notify_start_of_run BOOLEAN DEFAULT FALSE,
  notify_end_of_run BOOLEAN DEFAULT FALSE,
  notify_subsystem BOOLEAN DEFAULT FALSE
  /* TODO: Add filter fields */
  );
  
CREATE TABLE ReportPREFERENCES (
  fk_user_id INTEGER PRIMARY KEY REFERENCES Users(user_id)
  /* TODO: Add report preference stuff */
  );

CREATE TABLE Subsystems (
  subsystem_id SERIAL PRIMARY KEY,
  subsystem_name VARCHAR(32)
  );

CREATE TABLE SubsystemPermissions (
  fk_user_id INTEGER PRIMARY KEY REFERENCES Users(user_id),
  fk_subsystem_id INTEGER REFERENCES Subsystems(subsystem_id),
  is_member BOOLEAN,
  may_edit_eor_reason BOOLEAN
  /* TODO: Add more permissions */
  );

  
/* Runs */

CREATE TABLE Runs (
  run_number SERIAL PRIMARY KEY,
  time_run_start TIMESTAMP,
  time_data_start TIMESTAMP,
  time_data_end TIMESTAMP,
  time_run_end TIMESTAMP,
  activity_id VARCHAR(64),
  run_type RUN_TYPE_ENUM NOT NULL,
  run_quality RUN_QUALITY_ENUM NOT NULL DEFAULT 'UNKNOWN',
  n_detectors INTEGER NOT NULL DEFAULT 0,
  n_flps INTEGER NOT NULL DEFAULT 0,
  n_epns INTEGER NOT NULL DEFAULT 0,
  n_timeframes INTEGER NOT NULL DEFAULT 0,
  n_subtimeframes INTEGER NOT NULL DEFAULT 0,
  bytes_read_out INTEGER NOT NULL DEFAULT 0,
  bytes_timeframe_builder INTEGER NOT NULL DEFAULT 0
  );
  
CREATE TABLE EpnRoleSessions (
  epn_role_name CHAR(16),
  fk_run_number INTEGER,
  session_number SERIAL,
  epn_hostname VARCHAR(32) NOT NULL,
  n_subtimeframes INTEGER NOT NULL DEFAULT 0,
  bytes_in INTEGER NOT NULL DEFAULT 0,
  byte_out INTEGER NOT NULL DEFAULT 0,
  session_start TIMESTAMP NOT NULL DEFAULT now(),
  session_end TIMESTAMP,
  PRIMARY KEY(epn_role_name, fk_run_number, session_number)
  );
  
CREATE TABLE FlpRoles (
  flp_role_name CHAR(16),
  fk_run_number INTEGER,
  flp_hostname VARCHAR(32) NOT NULL,
  n_timeframes INTEGER NOT NULL DEFAULT 0,
  byte_processed INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(flp_role_name, fk_run_number)
  );
  
CREATE TABLE SubsystemsInRun (
  fk_run_number INTEGER REFERENCES Runs(run_number),
  fk_subsystem_id INTEGER REFERENCES Subsystems(subsystem_id), 
  run_quality RUN_QUALITY_ENUM NOT NULL DEFAULT 'UNKNOWN',
  PRIMARY KEY(fk_run_number, fk_subsystem_id)
  );
  
  
/* Revision history tables */

/*CREATE TABLE RunRevisionHistory (
  fk_run_number SERIAL PRIMARY KEY REFERENCES Runs(run_number),
  revision SERIAL PRIMARY KEY
  fk_changed_by_user_id INTEGER NOT NULL REFERENCES Users(user_id)
  );*/


/* Logs */

CREATE TABLE Logs (
  log_id SERIAL PRIMARY KEY,
  log_subtype LOG_SUBTYPE_ENUM,
  fk_user_id INTEGER NOT NULL REFERENCES Users(user_id),
  origin LOG_ORIGIN_ENUM NOT NULL,
  entry_type ENTRY_TYPE_ENUM NOT NULL,
  creation_time TIMESTAMP NOT NULL DEFAULT NOW(),
  title VARCHAR(255) NOT NULL,
  text VARCHAR(20000) NOT NULL,
  run_fk_run_number INTEGER REFERENCES Runs(run_number),
  announcement_valid_until TIMESTAMP,
  intervention_type INTERVENTION_TYPE_ENUM,
  issue_status ISSUE_STATUS_ENUM,
  comment_fk_parent_log_id INTEGER DEFAULT NULL REFERENCES Logs(log_id),
  comment_fk_root_log_id INTEGER DEFAULT NULL REFERENCES Logs(log_id)
  );
  
CREATE TABLE Attachments (
  file_id SERIAL PRIMARY KEY,
  fk_log_id INTEGER NOT NULL REFERENCES Logs(log_id),
  creation_time TIMESTAMP NOT NULL DEFAULT NOW(),
  title VARCHAR(255) NOT NULL,
  file_mime VARCHAR(8) NOT NULL,
  file_data_base64 BYTEA NOT NULL,
  file_md5 CHAR(16) NOT NULL
  );
  
CREATE TABLE InterventionLogs (
  fk_log_id INTEGER NOT NULL REFERENCES Logs(log_id),
  time_of_call TIMESTAMP NOT NULL,
  location VARCHAR(64) NOT NULL,
  action_taken VARCHAR(64) NOT NULL
  /* TODO: Add more stuff? */
  );

CREATE TABLE GasTemplateFields (
  fk_log_id INTEGER NOT NULL REFERENCES Logs(log_id),
  gas_type VARCHAR(16),
  gas_quantity FLOAT
  /* TODO: Add more stuff? */
  );
  
  
/* Tags */

CREATE TABLE Tags (
  fk_run_number INTEGER NOT NULL REFERENCES Runs(run_number),
  tag_id INTEGER PRIMARY KEY,
  tag_text VARCHAR(32) NOT NULL
  );
  
CREATE TABLE TagsInRun (
  fk_run_number INTEGER NOT NULL REFERENCES Runs(run_number),
  fk_tag_id INTEGER PRIMARY KEY REFERENCES Tags(tag_id)
  );

CREATE TABLE TagsInLog (
  fk_log_id INTEGER NOT NULL REFERENCES Logs(log_id),
  fk_tag_id INTEGER PRIMARY KEY REFERENCES Tags(tag_id)
  );

  
/* Stored procedures
   TODO:
    - Add procedure for adding a revision of a run: 
	  1) Move old revision from Runs to RunRevisionHistory
	  2) Add new run to Runs
*/
/*CREATE OR REPLACE FUNCTION add_run_revision(run_number INTEGER) 
RETURNS void AS $$
BEGIN

  INSERT INTO  VALUES (city, state);
END;
$$ LANGUAGE plpgsql;*/

-- Insert some dummy data
INSERT INTO Users (user_id, sams_id) VALUES (0, NULL);
-- INSERT INTO Runs (run_number) VALUES (0);

COMMIT;