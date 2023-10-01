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