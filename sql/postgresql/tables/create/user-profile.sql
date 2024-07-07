-- -----------------------------------------------------
-- @author: jcardona@mednet.ucla.edu
-- @creation-date: 2021-07-22
-- Table to store the user profile displayed on the app
-- By design it is just one profile record per user
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS "dgit_user_profile" (
    "user_id"           INTEGER NOT NULL
        CONSTRAINT dgit_user_id_fk
            REFERENCES users(user_id)
            ON DELETE CASCADE
        PRIMARY KEY,
    "email"             VARCHAR(100),
    "department"        VARCHAR(100),
    "office_location"   VARCHAR(100),
    "mobile_phone"      VARCHAR(25),
    "creation_user"     INTEGER NOT NULL
        CONSTRAINT ddgit_user_profile_creation_user_fk
            REFERENCES users(user_id)
            ON DELETE SET NULL,
    "creation_date"     TIMESTAMP DEFAULT now(),
    "modifying_user"    INTEGER
        CONSTRAINT dgit_user_profile_modifying_user_fk
            REFERENCES users(user_id)
            ON DELETE SET NULL,
    "last_modified"     TIMESTAMP,
    "active_p" BOOL     DEFAULT TRUE
);
