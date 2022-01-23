\ connect devbox

CREATE TABLE IF NOT EXISTS project (
    id SERIAL,
    name varchar(255) NOT NULL,
    description varchar(255) NOT NULL,
    keywords varchar(255) NOT NULL,
    logo_id bigint,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS module (
    id SERIAL,
    name varchar(255) NOT NULL,
    description varchar(255) NOT NULL,
    keywords varchar(255) NOT NULL,
    project_id bigint,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS template (
    id SERIAL,
    name varchar(255) NOT NULL,
    description varchar(255) NOT NULL,
    keywords varchar(255) NOT NULL,
    PRIMARY KEY (id)
);