\connect project

CREATE TABLE IF NOT EXISTS meta
(
    id SERIAL,
    name varchar(255) NOT NULL,
    description varchar(255) NOT NULL,
    keywords varchar(255) NOT NULL,
    PRIMARY KEY (id)
);