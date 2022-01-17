CREATE USER gitea WITH PASSWORD 'gitea';
CREATE DATABASE gitea;
GRANT ALL PRIVILEGES ON DATABASE gitea TO gitea;

\connect project

CREATE TABLE IF NOT EXISTS meta
(
    _id  INT  NOT NULL,
    data JSON NOT NULL,
    PRIMARY KEY (_id)
);