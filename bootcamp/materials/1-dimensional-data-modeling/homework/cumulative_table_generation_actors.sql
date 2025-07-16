-- Figure out first year in actor_films table
SELECT MIN(Year) AS first_year FROM actor_films;

WITH yesterday AS (
    SELECT *
    FROM Actors
    WHERE current_year = 1969
),

today as (
    SELECT *
    FROM actor_films
    WHERE year = 1970
)

/*
Use this query to see how the "yesterday" cte is null as it references the new actors table

-- SELECT *
-- FROM today t
-- FULL OUTER JOIN yesterday y
-- ON t.ActorId = y.ActorId

Next we want to coalesce the values that aren't temporal, or in other words, not changing
*/

-- notice that in this query, we select columns for which it brings in values for columns from the actors table
SELECT 
    COALESCE(t.Actor, y.Actor) AS Actor,
    COALESCE(t.ActorId, y.ActorId) AS ActorId,
    COALESCE(t.is_active, y.is_active) AS is_active,
    COALESCE(t.year, y.year) AS year,

    -- If null, creating initial array with a single value
    CASE 
        WHEN y.films IS NULL
        THEN ARRAY[
            ROW(t.Film, t.votes, t.Rating, t.FilmID)::film_struct
        ]

    -- If today is not null, then create the new value 
        WHEN t.year IS NOT NULL
        THEN y.films || ARRAY[
            ROW(t.Film, t.votes, t.Rating, t.FilmID)::film_struct
        ]

        -- Carry the history forward. E.g. If the actor retired, we still want to keep the films they acted in
        ELSE y.films 
    END AS films,
    COALESCE(t.year, y.year + 1) AS current_year
FROM today t
FULL OUTER JOIN yesterday y
ON t.ActorId = y.ActorId