-- We put things inside the basic_auth schema to hide
-- them from public view. Certain public procs/views will
-- refer to helpers and tables inside.
create schema if not exists basic_auth;

-- add type jwt
CREATE TYPE basic_auth.jwt_token AS (
  token text
);

CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA basic_auth;

-- following script is from url: https://github.com/michelp/pgjwt/blob/master/pgjwt--0.1.1.sql ###START###

CREATE OR REPLACE FUNCTION basic_auth.url_encode(data bytea) RETURNS text LANGUAGE sql AS $$
    SELECT translate(encode(data, 'base64'), E'+/=\n', '-_');
$$ IMMUTABLE;


CREATE OR REPLACE FUNCTION basic_auth.url_decode(data text) RETURNS bytea LANGUAGE sql AS $$
WITH t AS (SELECT translate(data, '-_', '+/') AS trans),
     rem AS (SELECT length(t.trans) % 4 AS remainder FROM t) -- compute padding size
    SELECT decode(
        t.trans ||
        CASE WHEN rem.remainder > 0
           THEN repeat('=', (4 - rem.remainder))
           ELSE '' END,
    'base64') FROM t, rem;
$$ IMMUTABLE;


CREATE OR REPLACE FUNCTION basic_auth.algorithm_sign(signables text, secret text, algorithm text)
RETURNS text LANGUAGE sql AS $$
WITH
  alg AS (
    SELECT CASE
      WHEN algorithm = 'HS256' THEN 'sha256'
      WHEN algorithm = 'HS384' THEN 'sha384'
      WHEN algorithm = 'HS512' THEN 'sha512'
      ELSE '' END AS id)  -- hmac throws error
SELECT basic_auth.url_encode(basic_auth.hmac(signables, secret, alg.id)) FROM alg;
$$ IMMUTABLE;


CREATE OR REPLACE FUNCTION basic_auth.sign(payload json, secret text, algorithm text DEFAULT 'HS256')
RETURNS text LANGUAGE sql AS $$
WITH
  header AS (
    SELECT basic_auth.url_encode(convert_to('{"alg":"' || algorithm || '","typ":"JWT"}', 'utf8')) AS data
    ),
  payload AS (
    SELECT basic_auth.url_encode(convert_to(payload::text, 'utf8')) AS data
    ),
  signables AS (
    SELECT header.data || '.' || payload.data AS data FROM header, payload
    )
SELECT
    signables.data || '.' ||
    basic_auth.algorithm_sign(signables.data, secret, algorithm) FROM signables;
$$ IMMUTABLE;


CREATE OR REPLACE FUNCTION basic_auth.verify(token text, secret text, algorithm text DEFAULT 'HS256')
RETURNS table(header json, payload json, valid boolean) LANGUAGE sql AS $$
  SELECT
    convert_from(basic_auth.url_decode(r[1]), 'utf8')::json AS header,
    convert_from(basic_auth.url_decode(r[2]), 'utf8')::json AS payload,
    r[3] = basic_auth.algorithm_sign(r[1] || '.' || r[2], secret, algorithm) AS valid
  FROM regexp_split_to_array(token, '\.') r;
$$ IMMUTABLE;


--- ###END###



create table if not exists
basic_auth.users (
  email    text primary key check ( email ~* '^.+@.+\..+$' ),
  pass     text not null check (length(pass) < 512),
  role     name not null check (length(role) < 512)
);


create or replace function
basic_auth.check_role_exists() returns trigger as $$
begin
  if not exists (select 1 from pg_roles as r where r.rolname = new.role) then
    raise foreign_key_violation using message =
      'unknown database role: ' || new.role;
    return null;
  end if;
  return new;
end
$$ language plpgsql;

drop trigger if exists ensure_user_role_exists on basic_auth.users;
create constraint trigger ensure_user_role_exists
  after insert or update on basic_auth.users
  for each row
  execute procedure basic_auth.check_role_exists();



-- Next we’ll use the pgcrypto extension and a trigger to keep passwords safe in the users table. ---START


create or replace function
basic_auth.encrypt_pass() returns trigger as $$
begin
  if tg_op = 'INSERT' or new.pass <> old.pass then
    new.pass = basic_auth.crypt(new.pass, gen_salt('bf'));
  end if;
  return new;
end
$$ language plpgsql;

drop trigger if exists encrypt_pass on basic_auth.users;
create trigger encrypt_pass
  before insert or update on basic_auth.users
  for each row
  execute procedure basic_auth.encrypt_pass();

  ---ENDE


  --- With the table in place we can make a helper to check a password against the encrypted column. It returns the database role for a user if the email and password are correct.

create or replace function
basic_auth.user_role(email text, pass text) returns name
  language plpgsql
  as $$
begin
  return (
  select role from basic_auth.users
   where users.email = user_role.email
     and users.pass = basic_auth.crypt(user_role.pass, users.pass)
  );
end;
$$;


--- Login
---As described in JWT from SQL, we’ll create a JWT inside our login function. Note that you’ll need to adjust the secret key which is hard-coded in this example to a secure (at least thirty-two character) secret of your choosing.



-- example user
--- INSERT INTO basic_auth.users(email, pass, role)	VALUES ('dominikbruhn@googlemail.com', '<password>', 'auth_user_all');


