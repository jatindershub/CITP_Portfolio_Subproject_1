/*
 ========================================
 Sektion 1: Tabeller jeg har arbejdet ud fra samt test data
 ========================================
*/

CREATE EXTENSION IF NOT EXISTS citext;
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username citext UNIQUE NOT NULL,
    password TEXT NOT NULL
);

/*
select * from users;
insert into users (username, password) values ('lolleren1','lolleren');
insert into users (username, password) values ('lolleren2','lolleren');
insert into users (username, password) values ('lolleren3','lolleren');
insert into users (username, password) values ('lolleren4','lolleren');
insert into users (username, password) values ('lolleren5','lolleren');
insert into users (username, password) values ('lolleren6','lolleren');
insert into users (username, password) values ('lolleren7','lolleren');
*/

CREATE TABLE Titles (
    title_id varchar PRIMARY KEY,
    title_type VARCHAR(255) NOT NULL,
    primary_title VARCHAR(255) NOT NULL,
    original_title VARCHAR(255) NOT NULL,
    is_adult BOOLEAN NOT NULL DEFAULT FALSE,
    start_year INTEGER,
    end_year INTEGER CHECK (end_year >= start_year OR end_year IS NULL),
    runtime_minutes INTEGER CHECK (runtime_minutes > 0 OR runtime_minutes IS NULL)
);

/*
insert into titles (title_id, title_type, primary_title, original_title, is_adult, start_year, end_year, runtime_minutes)
values ('tt0052520','tvSeries','The Twilight Zone','The Twilight Zone',false,2002,2003,40);
select * from titles;
*/


CREATE TABLE Bookmarks_title (
    user_id integer,
    title_id varchar references titles(title_id),
    PRIMARY KEY (user_id, title_id)
);


CREATE TABLE Bookmarks_person (
    user_id integer,
    person_id integer,
    PRIMARY KEY (user_id, person_id)
);


CREATE TABLE search_history(
    search_id SERIAL PRIMARY KEY,
    user_id integer,
    query_string TEXT NOT NULL,
    search_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- Index for hurtigere at hente en specifik brugers søgehistorik
CREATE INDEX idx_search_history_user_id
ON search_history(user_id);


create table Ratings (
    title_id varchar primary key references titles(title_id) on delete cascade,
    average_rating FLOAT DEFAULT 0
);

/*
select * from Ratings;
delete from Ratings;
*/

create table IndividualRatings (
    title_rating_id serial primary key,
    title_id varchar REFERENCES Titles(title_id),
    user_id INTEGER REFERENCES Users(user_id),
    rating integer not null,
    UNIQUE (title_id, user_id)
);



CREATE TABLE Frontend (
    frontend_id SERIAL PRIMARY KEY,
    poster TEXT,
    plot TEXT NOT NULL,
    title_id varchar REFERENCES Titles(title_id)
);

/*
 ========================================
 Sektion 2: Funktioner til Users
 ========================================
*/

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
     UPDATE users set password = newPassword where user_id = userIdInput;
     RETURN TRUE;
 EXCEPTION
 WHEN OTHERS THEN
     RAISE EXCEPTION 'Fejlbesked fra databasen: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

select UpdateUserPassword(12,'asdafasdafasfad');
drop function UpdateUserPassword(userIdInput integer, newPassword text);

select * from users


/*
 ========================================
 Sektion 3: Funktioner til Bookmarks
 ========================================
*/

----- CreateBookmarkTitle -----
CREATE OR REPLACE FUNCTION CreateBookmarkTitle(userIdInput integer, titleIdInput VARCHAR)
RETURNS BOOLEAN AS $$

BEGIN
    If userIdInput IS NULL OR titleIdInput IS NULL THEN
        RAISE EXCEPTION 'Fejl: userId eller titleID må ikke være angivet som NULL';
    end if;
  INSERT INTO bookmarks_title (user_id, title_id) values (userIdInput,titleIdInput);
  Return TRUE;
    EXCEPTION
WHEN unique_violation THEN
Raise exception  'Fejl: bookmark findes i forvejen';
 WHEN OTHERS THEN
     RAISE EXCEPTION 'Fejlbesked fra databasen: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

--select CreateBookmarkTitle(6,'tt0078672');
--drop function CreateBookmarkTitle(userIdInput integer, titleIdInput VARCHAR);



----- DeleteBookmarkTitle -----
CREATE OR REPLACE FUNCTION DeleteBookmarkTitle(userIdInput integer, titleIdInput VARCHAR)
RETURNS BOOLEAN AS $$

BEGIN
    If userIdInput IS NULL OR titleIdInput IS NULL THEN
        RAISE EXCEPTION 'Fejl: userId eller titleID må ikke være angivet som NULL';
    end if;
  Delete from bookmarks_title where user_id = userIdInput and title_id = titleIdInput;
    If not FOUND then
        raise exception 'Fejl: Bookmark med userId % og titleId % findes ikke',userIdInput, titleIdInput;
    end if;
  Return TRUE;
    EXCEPTION
 WHEN OTHERS THEN
     RAISE EXCEPTION 'Fejlbesked fra databasen: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

--select DeleteBookmarkTitle(6,'tt0078672');
--drop function DeleteBookmarkTitle(userIdInput integer, titleIdInput VARCHAR);


----- CreateBookmarkPerson -----
CREATE OR REPLACE FUNCTION CreateBookmarkPerson(userIdInput integer, personIdInput integer)
RETURNS BOOLEAN AS $$

BEGIN
    If userIdInput IS NULL OR personIdInput IS NULL THEN
        RAISE EXCEPTION 'Fejl: userId eller personID må ikke være angivet som NULL';
    end if;
  INSERT INTO bookmarks_person (user_id, person_id) values (userIdInput,personIdInput);
  Return TRUE;
    EXCEPTION
WHEN unique_violation THEN
Raise exception  'Fejl: bookmark findes i forvejen';
 WHEN OTHERS THEN
     RAISE EXCEPTION 'Fejlbesked fra databasen: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

--select CreateBookmarkPerson(23,2);
--drop function CreateBookmarkPerson(userIdInput integer, titleIdInput integer);



----- DeleteBookmarkPerson -----
CREATE OR REPLACE FUNCTION DeleteBookmarkPerson(userIdInput integer, personIdInput integer)
RETURNS BOOLEAN AS $$

BEGIN
    If userIdInput IS NULL OR personIdInput IS NULL THEN
        RAISE EXCEPTION 'Fejl: userId eller personID må ikke være angivet som NULL';
    end if;
  Delete from bookmarks_person where user_id = userIdInput and person_id = personIdInput;
    If not FOUND then
        raise exception 'Fejl: Bookmark med userId % og personId % findes ikke',userIdInput, personIdInput;
    end if;
  Return TRUE;
    EXCEPTION
 WHEN OTHERS THEN
     RAISE EXCEPTION 'Fejlbesked fra databasen: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

--select DeleteBookmarkPerson(23,33);
--drop function DeleteBookmarkPerson(userIdInput integer, personIdInput integer);



----- GetAllBookmarksPersonForUser -----
CREATE OR REPLACE FUNCTION GetAllBookmarksPersonForUser(userIdInput integer)
RETURNS SETOF record AS $$

BEGIN
    If userIdInput IS NULL THEN
        RAISE EXCEPTION 'Fejl: userId må ikke være angivet som NULL';
    end if;
  return query select * from bookmarks_person where user_id = userIdInput;
    If not FOUND then
        raise exception 'Bruger med id % har ikke nogle bookmarks for personer',userIdInput;
    end if;
    EXCEPTION
 WHEN OTHERS THEN
     RAISE EXCEPTION 'Fejlbesked fra databasen: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

--select * from GetAllBookmarksPersonForUser(23) as (BrugerId integer, PersonId integer);
--drop function GetAllBookmarksPersonForUser(userIdInput integer);



----- GetAllBookmarksForUser -----
CREATE OR REPLACE FUNCTION GetAllBookmarksForUser(userIdInput integer)
RETURNS SETOF record AS $$

BEGIN
    If userIdInput IS NULL THEN
        RAISE EXCEPTION 'Fejl: userId må ikke være angivet som NULL';
    end if;
  return query select * from bookmarks_title where user_id = userIdInput;
    If not FOUND then
        raise exception 'Bruger med id % har ikke nogle bookmarks for titler',userIdInput;
    end if;
    EXCEPTION
 WHEN OTHERS THEN
     RAISE EXCEPTION 'Fejlbesked fra databasen: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

--select * from GetAllBookmarksForUser(6) as (BrugerId integer, TitelId varchar);
--drop function GetAllBookmarksForUser(userIdInput integer);

/*
 ========================================
 Sektion 4: Funktioner til Search title
 ========================================
*/


----- SearchTitle -----
CREATE OR REPLACE FUNCTION SearchTitle(userIdInput integer, queryString varchar)
RETURNS TABLE(title_id INT, primary_title VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM RegisterSearch(userIdInput, queryString);

    RETURN QUERY select t.title_id, t.primary_title from titles
        t join frontend f on t.title_id = f.title_id
      where t.primary_title LIKE '%' || queryString || '%' or f.plot like '%' || queryString || '%';
END;
$$;

--select * from searchtitle(34,'test');
--select * from searchhistory;
--drop function searchtitle(querystring varchar);

----- GetSearchHistoryByUser -----
CREATE OR REPLACE FUNCTION GetSearchHistoryByUser(userIdInput integer)
RETURNS TABLE(search_id integer, user_id integer, query_string text, search_timestamp timestamp)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT searchId, userId, queryString, searchTimestamp
    FROM searchHistory
    WHERE userId = userIdInput
    ORDER BY searchTimestamp DESC;
END;
$$;

--SELECT * FROM GetSearchHistoryByUser(34);
--drop function GetSearchHistoryByUser(userIdInput integer);


----- RegisterSearch -----
CREATE OR REPLACE FUNCTION RegisterSearch(userIdInput INTEGER, queryStringInput TEXT)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO searchHistory (userId, queryString) VALUES (userIdInput, queryStringInput);
END;
$$;

/*
 ========================================
 Sektion 5: Funktioner or triggers til Ratings
 ========================================
*/

CREATE OR REPLACE FUNCTION UpdateAverageRating()
RETURNS TRIGGER AS $$
DECLARE
    v_average_rating FLOAT;
BEGIN
    -- Beregner den nye average rating
    SELECT AVG(rating)
    INTO v_average_rating
    FROM IndividualRatings
    WHERE title_id = NEW.title_id;

    -- indsætter en ny average rating, hvis den ikke allerede findes
    INSERT INTO Ratings (title_id, average_rating)
    VALUES (NEW.title_id, v_average_rating)
    ON CONFLICT (title_id)
    DO UPDATE SET average_rating = EXCLUDED.average_rating;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_update_average_rating
AFTER INSERT OR UPDATE ON IndividualRatings
FOR EACH ROW EXECUTE FUNCTION UpdateAverageRating();

/*
drop trigger tr_update_average_rating on individualratings;
select * from individualratings;
delete from individualratings;

insert into IndividualRatings (title_id, user_id, rating) values ('tt0052520',3,10);
insert into IndividualRatings (title_id, user_id, rating) values ('tt0052520',2,10);
insert into IndividualRatings (title_id, user_id, rating) values ('tt0052520',5,4);
insert into IndividualRatings (title_id, user_id, rating) values ('tt0052520',7,5);
insert into IndividualRatings (title_id, user_id, rating) values ('tt0052520',4,3);
insert into IndividualRatings (title_id, user_id, rating) values ('tt0052520',6,3);
*/




CREATE OR REPLACE FUNCTION fn_insert_or_update_rating()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM IndividualRatings WHERE title_id = NEW.title_id AND user_id = NEW.user_id) THEN
        UPDATE IndividualRatings
        SET rating = NEW.rating
        WHERE title_id = NEW.title_id AND user_id = NEW.user_id;
        RETURN NULL; -- eftersom rækken er opdateret er der ikke nogen grund til at indsætte den
    END IF;
    RETURN NEW; -- fortsætter med indsæt
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_insert_or_update_rating
BEFORE INSERT ON IndividualRatings
FOR EACH ROW EXECUTE FUNCTION fn_insert_or_update_rating();