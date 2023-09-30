----- IsUsernameTaken -----
CREATE OR REPLACE FUNCTION IsUsernameTaken(usernameInput VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
  usernameExist BOOLEAN;
BEGIN
    If usernameInput IS NULL THEN
        RAISE EXCEPTION 'Fejl: Brugernavn må ikke være angivet som NULL';
    end if;
  Select exists(select 1 from users where LOWER(users.username) = LOWER(usernameInput)) into usernameExist;
  RETURN usernameExist;
    EXCEPTION
 WHEN OTHERS THEN
     RAISE EXCEPTION 'Fejlbesked fra databasen: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- select IsUsernameTaken('brugernavn');
-- DROP FUNCTION IsUsernameTaken(VARCHAR);


----- CreateUser -----
CREATE OR REPLACE FUNCTION CreateUser(usernameInput citext, passwordInput TEXT)
 RETURNS BOOLEAN AS $$
 BEGIN
     If usernameInput IS NULL OR passwordInput IS NULL THEN
        RAISE EXCEPTION 'Fejl: Brugernavn eller adgangskode må ikke være angivet som NULL';
    end if;
     INSERT INTO users (username, password)
     VALUES (usernameInput, passwordInput);

     RETURN TRUE;
 EXCEPTION
 WHEN unique_violation THEN
    RAISE EXCEPTION 'Brugernavn % findes i forvejen',usernameInput;
 WHEN OTHERS THEN
     RAISE EXCEPTION 'Fejl: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- select CreateUser('brugernavn','adgangskode')
-- drop function CreateUser(usernameInput citext, passwordInput TEXT);


----- UpdateUser -----
CREATE OR REPLACE FUNCTION UpdateUserPassword(userIdInput integer, newPassword text)
RETURNS BOOLEAN AS $$
 BEGIN
     If userIdInput IS NULL OR newPassword IS NULL THEN
        RAISE EXCEPTION 'Fejl: userId eller newPassword må ikke være null';
    end if;
     UPDATE users set password = newPassword where userid = userIdInput;
     RETURN TRUE;
 EXCEPTION
 WHEN OTHERS THEN
     RAISE EXCEPTION 'Fejlbesked fra databasen: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

select UpdateUserPassword(12,'asdafasdafasfad');
drop function UpdateUserPassword(userIdInput integer, newPassword text);