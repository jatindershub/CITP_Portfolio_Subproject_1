----- CreateBookmarkTitle -----
CREATE OR REPLACE FUNCTION CreateBookmarkTitle(userIdInput integer, titleIdInput VARCHAR)
RETURNS BOOLEAN AS $$

BEGIN
    If userIdInput IS NULL OR titleIdInput IS NULL THEN
        RAISE EXCEPTION 'Fejl: userId eller titleID må ikke være angivet som NULL';
    end if;
  INSERT INTO bookmarks (userid, titleid) values (userIdInput,titleIdInput);
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
  Delete from bookmarks where userid = userIdInput and titleid = titleIdInput;
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
  INSERT INTO bookmarksperson (userid, personid) values (userIdInput,personIdInput);
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
  Delete from bookmarksperson where userid = userIdInput and personid = personIdInput;
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
  return query select * from bookmarksperson where userid = userIdInput;
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
  return query select * from bookmarks where userid = userIdInput;
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

