---------------------------------------------------------------------------  
-- GAME OF THRONES death predictor  
-- SQL Table Creation
-- IMPORTANT! This script is made to be run in a SQL instance (i.e. EC2)
---------------------------------------------------------------------------  
  
CREATE DATABASE got;  
  
\\connect got  
  
---------------------------------------------------------------------------  
-- Information of deaths in books 1-5  
---------------------------------------------------------------------------  
  
CREATE TABLE raw01_character_death (  
    Name TEXT NULL,  
    Allegiances TEXT NULL,  
    Death_Yr INT NULL,  
    Death_Bk INT NULL,  
    Death_Chp INT NULL,  
    Apperance_Chp INT NULL,  
    Gender INT NULL,  
    Nobility INT NULL,  
    book1 INT NULL,  
    book2 INT NULL,  
    book3 INT NULL,  
    book4 INT NULL,  
    book5 INT NULL  
);  
  
COPY raw01_character_death FROM '/home/ubuntu/GOT/01_character-deaths.csv' DELIMITER ',' CSV HEADER;  
  
SELECT * FROM raw01_character_death;  
# 917  
  
---------------------------------------------------------------------------  
-- General Information of characters in books 1-5  
---------------------------------------------------------------------------  
  
CREATE TABLE raw01_character (  
    Id INT NULL,  
    isAlive INT NULL,  
    predict_dth TEXT NULL,  
    prob_alive FLOAT NULL,  
    prob_death FLOAT NULL,  
    name TEXT NULL,  
    title TEXT NULL,  
    male INT NULL,  
    culture TEXT NULL,  
    Birth_Yr INT NULL,  
    Death_Yr INT NULL,  
    mother TEXT NULL,  
    father TEXT NULL,  
    heir TEXT NULL,  
    house TEXT NULL,  
    spouse TEXT NULL,  
    book1 INT NULL,  
    book2 INT NULL,  
    book3 INT NULL,  
    book4 INT NULL,  
    book5 INT NULL,  
    isAliveMother INT NULL,  
    isAliveFather INT NULL,  
    isAliveHeir INT NULL,  
    isAliveSpouse INT NULL,  
    isMarried INT NULL,  
    isNoble INT NULL,  
    age INT NULL,  
    numDeadRelations INT NULL,  
    boolDeadRelations INT NULL,  
    isPopular INT NULL,  
    popularity FLOAT NULL,  
    isAlive2 INT NULL  
);  
  
COPY raw01_character FROM '/home/ubuntu/GOT/csv/01_character-predictions_S5.csv' DELIMITER ',' CSV HEADER;  
# 1946   
  
SELECT * FROM raw01_character;  
  
---------------------------------------------------------------------------  
-- Quick EDA in SQL  
---------------------------------------------------------------------------  
  
SELECT COUNT(DISTINCT T1.NAME)  
FROM raw01_character T1  
INNER JOIN raw01_character_death T2  
ON lower(T1.name) = LOWER(T2.Name)  
# 1704 (Out of 1946)  
# Unique values: 851  
  
----------------------------------  
-- Categorical Variable Analysis  
----------------------------------  
  
SELECT COUNT(DISTINCT SUBSTRING(title,1,4)) FROM raw01_character;  
#140  
  
SELECT COUNT(DISTINCT culture) FROM raw01_character;  
# 64  
  
SELECT SUBSTRING(LOWER(culture), 1, 5), COUNT(*) FROM raw01_character  
GROUP BY 1  
ORDER BY 2 DESC;  
# 39  
  
  
SELECT DISTINCT LOWER(house) FROM raw01_character where house like '%annister';  
# 347  
  
SELECT LOWER(house), COUNT(*) FROM raw01_character  
GROUP BY 1  
ORDER BY 2 DESC;  
# Take house with at least 10 characters  
  
SELECT LOWER(house) as house, COUNT(*) as c   
FROM raw01_character  
GROUP BY house  
HAVING COUNT(*) >=10;  
  
SELECT LOWER(allegiances) as house, COUNT(*) as c   
FROM raw01_character_death  
GROUP BY allegiances  
HAVING COUNT(*) >=10;  
  
SELECT  
CASE WHEN LOWER(T2.allegiances) = 'none' THEN LOWER(T1.house)  
    WHEN LOWER(T2.allegiances) NOT LIKE 'house %' THEN 'house '||LOWER(T2.allegiances)  
ELSE LOWER(T2.allegiances) END house,  
count(*)  
FROM raw01_character T1  
INNER JOIN raw01_character_death T2  
ON LOWER(T1.name) = LOWER(T2.Name)  
GROUP BY 1  
ORDER BY 2 DESC  
HAVING count(*) >= 10;  
  
----------------------------------  
-- Character Relation Analysis  
----------------------------------  
  
SELECT CASE WHEN mother IS NULL THEN False ELSE True END as hasMom, COUNT(*) as c   
FROM raw01_character  
GROUP BY hasMom;  
# Only 21 characters have known Mom  
  
SELECT CASE WHEN father IS NULL THEN False ELSE True END as hasDad, COUNT(*) as c   
FROM raw01_character  
GROUP BY hasDad;  
# Only 26 characters have known Dad  
  
SELECT CASE WHEN heir IS NULL THEN False ELSE True END as hasHeir, COUNT(*) as c   
FROM raw01_character  
GROUP BY hasheir;  
# Only 23 characters have known Heir  
  
SELECT CASE WHEN spouse IS NULL THEN False ELSE True END as hasSpouse, COUNT(*) as c   
FROM raw01_character  
GROUP BY hasSpouse;  
# 276 characters have known Spouse  
  
----------------------------------  
-- Final Query 1 -> Pandas  
----------------------------------  
  
SELECT DISTINCT  
    C.name,  
    C.isAlive,  
    -- Boolean original features  
    C.male,  
    C.book1  ,  
    C.book2  ,  
    C.book3  ,  
    C.book4  ,  
    C.book5  ,  
    C.isAliveMother  ,  
    C.isAliveFather  ,  
    C.isAliveHeir  ,  
    C.isAliveSpouse  ,  
    C.isMarried  ,  
    C.isNoble  ,  
    C.boolDeadRelations  ,  
    C.isPopular  ,  
    C2.Death_Bk  ,  
    C2.Apperance_Chp,  
      
    -- Boolean Transformed Features  
    CASE WHEN C.mother IS NULL THEN 0 ELSE 1 END as hasMom,  
    CASE WHEN C.father IS NULL THEN 0 ELSE 1 END as hasDad,  
    CASE WHEN C.heir IS NULL THEN 0 ELSE 1 END as hasHeir ,  
    CASE WHEN C.spouse IS NULL THEN 0 ELSE 1 END as hasSpouse  ,  
      
    -- Numerical Original Features  
    C.age,  
    C.numDeadRelations,  
    C.popularity,  
      
    -- Categorical Transformed Features  
    SUBSTRING(C.culture, 1, 5) culture,  
    CASE WHEN C.house IS NULL THEN 'Unknown'   
        WHEN H.house IS NULL THEN 'Other'   
        ELSE UPPER(C.house) END as house  
  
FROM raw01_character AS C  
LEFT OUTER JOIN (SELECT  
    CASE WHEN UPPER(T2.allegiances) = 'none' THEN UPPER(T1.house)  
        WHEN UPPER(T2.allegiances) NOT LIKE 'house %' THEN 'house '||UPPER(T2.allegiances)  
    ELSE UPPER(T2.allegiances) END house,  
    count(*)  
    FROM raw01_character T1  
    INNER JOIN raw01_character_death T2  
    ON UPPER(T1.name) = UPPER(T2.Name)  
    GROUP BY 1  
    HAVING count(*) >= 10) AS H  
ON UPPER(C.house) = UPPER(H.house)  
  
INNER JOIN raw01_character_death C2  
ON UPPER(C.name) = UPPER(C2.Name);  
  
  
---------------------------------------------------------------------------  
-- General Information of characters in tv show 1-6  
---------------------------------------------------------------------------  
  
CREATE TABLE raw11_character_S6 (  
    name TEXT NULL,  
    actor TEXT NULL,  
    time_S1 TEXT NULL,  
    time_S2 TEXT NULL,  
    time_S3 TEXT NULL,  
    time_S4 TEXT NULL,  
    full_time_S1 TEXT NULL,  
    full_time_S2 TEXT NULL,  
    full_time_S3 TEXT NULL,  
    full_time_S4 TEXT NULL,  
    total_time TEXT NULL,  
    total_episode_num INT NULL,  
    season1 TEXT NULL,  
    season2 TEXT NULL,  
    season3 TEXT NULL,  
    season4 TEXT NULL,  
    isAlive TEXT NULL,  
    death_season INT NULL,  
    death_by TEXT NULL,  
    check_season INT NULL,  
    allegiance TEXT NULL,  
    age INT NULL,  
    enter TEXT NULL  
);  
  
COPY raw11_character_S6 FROM '/home/ubuntu/GOT/csv/11_Character Data-S6.csv' DELIMITER ',' CSV HEADER;  
# 122  
  
---------------------------------------------------------------------------  
-- General Information of tv show episodes 1-6  
---------------------------------------------------------------------------  
  
CREATE TABLE raw11_episodes_tv (  
    season_ep INT NULL,  
    episode INT NULL,  
    title TEXT NULL,  
    rating FLOAT NULL,  
    viewers FLOAT NULL,  
    season INT NULL  
);  
  
COPY raw11_episodes_tv FROM '/home/ubuntu/GOT/11_Episodes.csv' DELIMITER ',' CSV HEADER;  
# 40  
  
---------------------------------------------------------------------------  
-- Quick EDA in SQL  
---------------------------------------------------------------------------  
  
DELETE FROM raw11_character_tv WHERE NAME IS NULL;  
# 1  
  
SELECT isAlive, COUNT(*)   
FROM raw11_character_tv   
GROUP BY 1;  
# 3 vales found: Alive, Deseaced, Unknown???  
  
SELECT name   
FROM raw11_character_tv   
WHERE isAlive ='Unknown';  
  
UPDATE raw11_character_tv SET isAlive = 'Deceased' WHERE name = 'Doreah';    
# Danys servant, locked down to deth  
  
UPDATE raw11_character_tv SET isAlive = 'Deceased' WHERE name = 'Xaro Xhoan Daxos';  
# Locked down to death  
  
UPDATE raw11_character_tv SET isAlive = 'Alive' WHERE name = 'Benjen Stark';  
# Came back to life (Alive)  
  
---------------------------------------------------------------------------  
-- Join Test on Both datasets  
---------------------------------------------------------------------------  
  
SELECT T1.name  AS name, COUNT(*) AS c  
FROM raw11_character_tv T1  
INNER JOIN raw01_character T2  
ON LOWER(T1.name) = LOWER(T2.Name)  
# 96  
# 25 main charcters (order ny importance) missing.  Better join in pandas (FuzzyWuzzy)  
  
  
SELECT T1.name  
FROM raw11_character_tv T1  
LEFT OUTER JOIN raw01_character T2  
ON LOWER(T1.name) = LOWER(T2.Name)  
WHERE T2.male IS NULL  
# 0  
  
SELECT T1.name  
FROM raw11_character_tv T1  
RIGHT OUTER JOIN raw01_character T2  
ON LOWER(T1.name) = LOWER(T2.Name)  
WHERE T2.male IS NULL  
# 0  
  
SELECT  
    season,  
    AVG(rating) rating,  
    AVG(viewers) avg_viewers,  
    SUM(viewers) total_viewers  
FROM raw11_episodes_tv  
GROUP BY 1;  
  
----------------------------------  
-- Final Query 2 -> Pandas  
----------------------------------  
  
SELECT  
    name  ,  
    CASE WHEN C.isAlive = 'Alive' THEN 1 ELSE 0 END isAlive_shw , --Si no en kb: 1  
    C.death_season  , --Si no en kb: NULL  
    COALESCE(CAST(NULLIF(LEFT(C.time_S1,POSITION(':' IN C.time_S1)-1), '') AS INT)*60 +   
             CAST(NULLIF(RIGHT(C.time_S1,2), '') AS INT),0) time_s1,    --Si no en kb: 0 en todas  
    COALESCE(CAST(NULLIF(LEFT(C.time_S2,POSITION(':' IN C.time_S2)-1), '') AS INT)*60 +   
             CAST(NULLIF(RIGHT(C.time_S2,2), '') AS INT),0) time_s2,  
    COALESCE(CAST(NULLIF(LEFT(C.time_S3,POSITION(':' IN C.time_S3)-1), '') AS INT)*60 +   
             CAST(NULLIF(RIGHT(C.time_S3,2), '') AS INT),0) time_s3,  
    COALESCE(CAST(NULLIF(LEFT(C.time_S4,POSITION(':' IN C.time_S4)-1), '') AS INT)*60 +   
             CAST(NULLIF(RIGHT(C.time_S4,2), '') AS INT),0) time_s4,  
    C.total_episode_num,  --Si no en kb: 0  
    CASE WHEN C.season1 = 'TRUE' THEN 1 ELSE 0 END season1,  --Si no en kb: 0 en todas  
    CASE WHEN C.season2 = 'TRUE' THEN 1 ELSE 0 END season2 ,  
    CASE WHEN C.season3 = 'TRUE' THEN 1 ELSE 0 END season3  ,  
    CASE WHEN C.season4 = 'TRUE' THEN 1 ELSE 0 END season4  ,  
    COALESCE(H.house, 'Other') house_shw,  --Si no en kb: Other  
    C.age_shw --Si no en kb: mean  
FROM raw11_character_tv C  
INNER JOIN (  
    SELECT LEFT(  
            CASE WHEN POSITION(E'\\n' IN allegiance) = 0 THEN allegiance  
            ELSE LEFT(allegiance,COALESCE(POSITION(E'\\n' IN allegiance)-1,0))   
            END, 15) house,   
        COUNT(*)  
    FROM raw11_character_tv C  
    GROUP BY 1  
    HAVING COUNT(*) > 3) AS H  
    ON H.house = LEFT(  
            CASE WHEN POSITION(E'\\n' IN C.allegiance) = 0 THEN C.allegiance  
            ELSE LEFT(C.allegiance,COALESCE(POSITION(E'\\n' IN C.allegiance)-1,0))   
            END, 15)  
  
---------------------------------------------------------------------------  
--  TV Series General impormation Seasons 1-7  
---------------------------------------------------------------------------  
  
CREATE TABLE raw03_character_tv (  
    char_id TEXT NULL,  
    name TEXT NULL  
);  
  
COPY raw03_character_tv FROM '/home/ubuntu/GOT/csv/03_characters.csv' DELIMITER ',' CSV HEADER;  
# 638  
  
UPDATE raw03_character_tv  
SET name = LEFT(name, LENGTH(name)-1)  
  
CREATE TABLE raw03_character_episode_tv (  
    episode INT NULL,  
    char_id TEXT NULL  
);  
  
COPY raw03_character_episode_tv FROM '/home/ubuntu/GOT/csv/03_character_episode.csv' DELIMITER ',' CSV HEADER;  
# 2725  
  
UPDATE raw03_character_episode_tv  
SET char_id = LEFT(char_id, LENGTH(char_id)-1);  
  
---------------------------------------------------------------------------  
-- Quick EDA in SQL  
---------------------------------------------------------------------------  
  
SELECT C.name  
FROM raw03_character_tv C2  
RIGHT JOIN raw11_character_tv C  
ON C.name = C2.name  
WHERE C2.CHAR_ID is null;  
# 19 Important Characters (Catelyn, Bran, Lancel, Drogo) are missing : Fuzzy!  
  
INNER JOIN raw03_character_episode_tv E  
ON C.char_id = E.char_id;  
# 104  
  
SELECT  
    AVG(rating) rating, -- 8.525  
    SUM(rating) rating, -- 341  
    AVG(viewers) avg_viewers, -- 4.531  
    SUM(viewers) total_viewers -- 181.23  
FROM raw11_episodes_tv;  
  
----------------------------------  
-- Final Query 3 -> Pandas  
----------------------------------  
  
SELECT  
    C.name,  
    SUM(E7.rating)/341 sum_rating_S7,  
    SUM(E7.viewers)/181.23 total_viewers_S7,  
FROM raw03_character_tv C  
INNER JOIN raw03_character_episode_tv CE  
ON C.char_id = CE.char_id  
INNER JOIN raw11_episodes_tv E7  
ON CE.episode = E7.episode  
GROUP BY 1  
ORDER BY 3 DESC;
