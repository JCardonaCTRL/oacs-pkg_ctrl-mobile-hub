-- -----------------------------------------------------
-- @author: jcardona@mednet.ucla.edu
-- @creation-date: 2021-06-01
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS "dgit_tracking_events" (
    "tracking_id"       INTEGER NOT NULL
        CONSTRAINT dgit_tracking_events_pk
                PRIMARY KEY,
    "tile_code"         VARCHAR(100),
    "tile_module"       VARCHAR(100),
    "action"            VARCHAR(100),
    "context"           TEXT,
    "creation_user"     INTEGER NOT NULL
        CONSTRAINT dgit_tracking_events_creation_user_fk
            REFERENCES users(user_id)
            ON DELETE SET NULL,
    "creation_date"     TIMESTAMP DEFAULT now(),
    "modifying_user"    INTEGER
        CONSTRAINT dgit_tracking_events_modifying_user_fk
            REFERENCES users(user_id)
            ON DELETE SET NULL,
    "last_modified"     TIMESTAMP,
    "active_p" BOOL DEFAULT TRUE
);
