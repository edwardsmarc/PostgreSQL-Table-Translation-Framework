﻿------------------------------------------------------------------------------
-- PostgreSQL Table Tranlation Engine - Test file
-- Version 0.1 for PostgreSQL 9.x
-- https://github.com/edwardsmarc/postTranslationEngine
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2020 Pierre Racine <pierre.racine@sbf.ulaval.ca>, 
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
--
-------------------------------------------------------------------------------
SET lc_messages TO 'en_US.UTF-8';

-- Create a test source table
DROP TABLE IF EXISTS test_sourcetable1;
CREATE TABLE test_sourcetable1 AS
SELECT 'a'::text id, 1 height
UNION ALL
SELECT 'b'::text, 3 height
UNION ALL
SELECT 'c'::text, 5 height;

-- Create a test translation table
DROP TABLE IF EXISTS test_translationTable;
CREATE TABLE test_translationTable AS
SELECT 'CROWN_CLOSURE_UPPER'::text targetAttribute,
       'int'::text targetAttributeType,
       'notNull(crown_closure, -8888);between(crown_closure, 0, 100, -9999)'::text validationRules,
       'copy(crown_closure)'::text translationRules,
       'Test'::text description,
       TRUE descUpToDateWithRules
UNION ALL
SELECT 'CROWN_CLOSURE_LOWER'::text targetAttribute,
       'int'::text targetAttributeType,
       'notNull(crown_closure, -8888);between(crown_closure, 0, 100, -9999)'::text validationRules,
       'copy(crown_closure)'::text translationRules,
       'Test'::text description,
       TRUE descUpToDateWithRules;

--SELECT * FROM test_translationTable;

-----------------------------------------------------------
-- Comment out the following line and the last one of the file to display 
-- only failing tests
--SELECT * FROM (
-----------------------------------------------------------
-- The first table in the next WITH statement list all the function tested
-- with the number of test for each. It must be adjusted for every new test.
-- It is required to list tests which would not appear because they failed
-- by returning nothing.
WITH test_nb AS (
    SELECT 'TT_FullTableName'::text function_tested, 1 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_ValidateTTable'::text,                2,          0         UNION ALL
    SELECT 'TT_Prepare'::text,                       3,          0         UNION ALL
    SELECT '_TT_Translate'::text,                    4,          0
),
test_series AS (
-- Build a table of function names with a sequence of number for each function to be tested
SELECT function_tested, maj_num, generate_series(1, nb_test)::text min_num 
FROM test_nb
)
SELECT coalesce(maj_num || '.' || min_num, b.number) number,
       coalesce(a.function_tested, 'ERROR: Insufficient number of test for ' || 
                b.function_tested || ' in the initial table...') function_tested,
       description, 
       NOT passed IS NULL AND (regexp_split_to_array(number, '\.'))[2] = min_num AND passed passed
FROM test_series a FULL OUTER JOIN (

---------------------------------------------------------
-- Test 1 - TT_FullTableName
---------------------------------------------------------
---------------------------------------------------------

SELECT '1.1'::text number,
       'TT_FullTableName'::text function_tested,
       'Basic test'::text description,
       TT_FullTableName('public', 'test') = 'public.test' passed

---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'TT_FullTableName'::text function_tested,
       'Null schema'::text description,
       TT_FullTableName(NULL, 'test') = 'public.test' passed
---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'TT_FullTableName'::text function_tested,
       'Both NULL parameters'::text description,
        TT_FullTableName(NULL, NULL) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'TT_FullTableName'::text function_tested,
       'Table name starting with a digit'::text description,
        TT_FullTableName(NULL, '1table')  = 'public."1table"' passed
---------------------------------------------------------
UNION ALL
SELECT '1.5'::text number,
       'TT_FullTableName'::text function_tested,
       'Both names starting with a digit'::text description,
        TT_FullTableName('1schema', '1table')  = '"1schema"."1table"' passed
---------------------------------------------------------
) b 
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num) 
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
--) foo WHERE NOT passed;

--SELECT TT_Prepare('public', 'test_translationtable');

--SELECT * FROM TT_Translate('public', 'test_sourcetable1')

--SELECT (TT_Translate('public', 'test_sourcetable1')).*
