--- braucht man das, wenn man die var PGRST_DB_CONFIG über DOcker setzt ? ALTER DATABASE nidoca SET "pgrst.jwt_secret" TO '<jwt secret>';

-- login should be on your exposed schema
create or replace function
login(email text, pass text) returns basic_auth.jwt_token as $$
declare
  _role name;
  result basic_auth.jwt_token;
begin
  -- check email and password
  select basic_auth.user_role(email, pass) into _role;
  if _role is null then
    raise invalid_password using message = 'invalid user or password';
  end if;

  select basic_auth.sign(
      row_to_json(r), current_setting('pgrst.jwt_secret')
    ) as token
    from (
      select _role as role, login.email as email,
         extract(epoch from now())::integer + 60*60 as exp
    ) r
    into result;
  return result;
end;
$$ language plpgsql security definer;


CREATE ROLE authenticator noinherit login password '<password>';

CREATE ROLE web_anonym nologin;
GRANT web_anonym to authenticator;
GRANT usage ON schema public TO web_anonym;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO web_anonym;
REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM web_anonym;

CREATE ROLE auth_user_all nologin;
GRANT auth_user_all to authenticator;
GRANT usage on schema public to auth_user_all;
GRANT ALL ON ALL TABLES IN SCHEMA public TO auth_user_all;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO auth_user_all;

GRANT EXECUTE ON FUNCTION public.login(email text, pass text) TO web_anonym;
