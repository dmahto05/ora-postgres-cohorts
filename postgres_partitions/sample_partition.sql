CREATE SCHEMA data_mart;
   
CREATE TABLE data_mart.organization( 
    org_id          SERIAL,
    org_name        TEXT,
    CONSTRAINT pk_organization PRIMARY KEY (org_id) 
);


/* In below example, created_at column is used as partition key for the table and is also included as part of the primary key, to enforce uniqueness across partitions */

CREATE TABLE data_mart.events_daily(
    event_id        INT,
    operation       VARCHAR(1),
    value           FLOAT(24),
    parent_event_id INT,
    event_type      VARCHAR(25),
    org_id          INT,
    created_at      TIMESTAMPTZ,
    CONSTRAINT pk_data_mart_events_daily PRIMARY KEY (event_id, created_at),
    CONSTRAINT ck_valid_operation CHECK (operation = 'C' OR operation = 'D'),
    CONSTRAINT fk_orga_membership_events_daily FOREIGN KEY(org_id)
    REFERENCES data_mart.organization (org_id),
    CONSTRAINT fk_parent_event_id_events_daily FOREIGN KEY(parent_event_id, created_at)
    REFERENCES data_mart.events_daily (event_id,created_at)
) PARTITION BY RANGE (created_at);

CREATE INDEX idx_org_id_events_daily     ON data_mart.events_daily(org_id);
CREATE INDEX idx_event_type_events_daily ON data_mart.events_daily(event_type);

CREATE TABLE data_mart.events_monthly(
    event_id        INT,
    value           FLOAT(24),
    parent_event_id INT,
    org_id          INT,
    created_at      TIMESTAMPTZ,
    CONSTRAINT pk_data_mart_events_monthly PRIMARY KEY (event_id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE data_mart.events_quarterly(
    event_id        INT,
    value           FLOAT(24),
    parent_event_id INT,
    org_id          INT,
    created_at      TIMESTAMPTZ,
    CONSTRAINT pk_data_mart_events_quarterly PRIMARY KEY (event_id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE data_mart.events_yearly(
    event_id        INT,
    value           FLOAT(24),
    parent_event_id INT,
    org_id          INT,
    created_at      TIMESTAMPTZ,
    CONSTRAINT pk_data_mart_events_yearly PRIMARY KEY (event_id, created_at)
) PARTITION BY RANGE (created_at);
