﻿------------------------------------------------------------------------------
-- PostgreSQL Table Tranlation Engine - Helper functions installation file
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
--
--
-------------------------------------------------------------------------------
-- Begin Validation Function Definitions...
-- Validation functions return only boolean values (TRUE or FALSE).
-------------------------------------------------------------------------------
-- TT_NotNull
--
--  var text/boolean/double precision/int  - Value to test for NOT NULL.
--
-- Return TRUE if val is not NULL.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotNull(
  val text
)
RETURNS boolean AS $$
  BEGIN
    RETURN val IS NOT NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_NotNull(
  val double precision
)
RETURNS boolean AS $$
  BEGIN
    RETURN val IS NOT NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_NotNull(
  val boolean
)
RETURNS boolean AS $$
  SELECT TT_NotNull(val::text);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_NotNull(
  val int
)
RETURNS boolean AS $$
  SELECT TT_NotNull(val::double precision);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_NotEmpty
--
--  val text  - Value to test for empty string.
--
-- Return TRUE if val is not empty.
-- Return FALSE if val is empty string or padded spaces (e.g. '' or '  ') or Null.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotEmpty(
   val text
)
RETURNS boolean AS $$
  DECLARE
  BEGIN
    val = TRIM(val); -- trim removes any spaces before evaluating string.
    IF val IS NULL OR val = '' THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE; 
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsInt
--
--  val double precision/int/text - Value to test
--  Must be numeric but cannot be decimal
--  Null values return FALSE
--  Strings with numeric characters and '.' will be passed to IsInt
--  Strings with anything else (e.g. letter characters) return FALSE.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsInt(
   val double precision
)
RETURNS boolean AS $$
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN val - val::int = 0;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsInt(
   val int
)
RETURNS boolean AS $$
  SELECT TT_IsInt(val::double precision);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsInt(
   val text
)
RETURNS boolean AS $$
  DECLARE
    x double precision;
  BEGIN
    x = val::double precision;
    RETURN TT_IsInt(val::double precision);
  EXCEPTION WHEN OTHERS THEN
      RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsNumeric
--
--  val double precision/int/text - Value to test.
--  Must be numeric, can be decimal, can be integer.
--  Null values return FALSE
--  Strings with numeric characters and '.' will be passed to IsNumeric
--  Strings with anything else (e.g. letter characters) return FALSE.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsNumeric(
   val text
)
  RETURNS boolean AS $$
    DECLARE
      x double precision;
    BEGIN
      IF val IS NULL THEN
        RETURN FALSE;
      ELSE
        x = val::double precision;
        RETURN TRUE;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      RETURN FALSE;
    END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsNumeric(
   val int
)
RETURNS boolean AS $$
  SELECT TT_IsNumeric(val::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsNumeric(
   val double precision
)
RETURNS boolean AS $$
  SELECT TT_IsNumeric(val::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Between
--
-- val double precision/int  - Value to test.
-- min double precision  - Minimum.
-- max double precision  - Maximum.
--
-- Return TRUE if var is between min and max.
-- Return FALSE otherwise.
-- Return FALSE if val is NULL.
-- Return error if min or max are null.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Between(
  val double precision,
  min double precision,
  max double precision
)
RETURNS boolean AS $$
  BEGIN
    IF min IS NULL OR max IS NULL THEN
      RAISE EXCEPTION 'min or max is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN val > min and val < max;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Between(
  val int,
  min double precision,
  max double precision
)
RETURNS boolean AS $$
  SELECT TT_Between(val::double precision,min,max);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GreaterThan
--
--  val double precision/int - Value to test.
--  lowerBound double precision - lower bound to test against
--  inclusive boolean - is lower bound inclusive? Default True
--
--  Return TRUE if val >= lowerBound and inclusive = TRUE.
--  Return TRUE if val > lowerBound and inclusive = FALSE.
--  Return FALSE otherwise.
--  Return FALSE if val is NULL.
--  Return error if lowerBound or inclusive are null.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_GreaterThan(
   val double precision,
   lowerBound double precision,
   inclusive boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  BEGIN
    IF lowerBound IS NULL OR inclusive IS NULL THEN
      RAISE EXCEPTION 'lowerBound or inclusive is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSIF inclusive = TRUE THEN
      RETURN val >= lowerBound;
    ELSE
      RETURN val > lowerBound;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_GreaterThan(
   val int,
   lowerBound double precision,
   inclusive boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  SELECT TT_GreaterThan(val::double precision,lowerBound,inclusive);
$$ LANGUAGE sql VOLATILE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_LessThan
--
--  val double precision/int - Value to test.
--  upperBound double precision - upper bound to test against
--  inclusive boolean - is upper bound inclusive? Default True
--
--  Return TRUE if val <= upperBound and inclusive = TRUE.
--  Return TRUE if val < upperBound and inclusive = FALSE.
--  Return FALSE otherwise.
--  Return FALSE if val is NULL.
--  Return error if upperBound or inclusive are null.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_LessThan(
   val double precision,
   upperBound double precision,
   inclusive boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  BEGIN
    IF upperBound IS NULL OR inclusive IS NULL THEN
      RAISE EXCEPTION 'upperBound or inclusive is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSIF inclusive = TRUE THEN
      RETURN val <= upperBound;
    ELSE
      RETURN val < upperBound;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_LessThan(
   val int,
   upperBound double precision,
   inclusive boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  SELECT TT_LessThan(val::double precision,upperBound,inclusive);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsOccurence (table version)
--
-- val text/double precision/int - column to test.
-- lookupSchemaName name - schema name holding lookup table
-- lookupTableName name - lookup table
-- occurences - int
--
-- if number of occurences of val in first column of schema.table equals occurences, return true.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsOccurence(
  val text,
  lookupSchemaName name,
  lookupTableName name,
  occurences int
)
RETURNS boolean AS $$
  DECLARE
    query text;
    return boolean;
  BEGIN
    IF lookupSchemaName IS NULL OR lookupTableName IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName is null';
    ELSIF occurences IS NULL THEN
      RAISE EXCEPTION 'occurences is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSE
      query = 'SELECT (SELECT COUNT(*) FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ' WHERE ' || (TT_TableColumnNames(lookupSchemaName, lookupTableName))[1] || ' = ' || quote_literal(val) || ') = ' || occurences || ';';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsOccurence(
  val double precision,
  lookupSchemaName name,
  lookupTableName name,
  occurences int
)
RETURNS boolean AS $$
  DECLARE
    query text;
    return boolean;
  BEGIN
    IF lookupSchemaName IS NULL OR lookupTableName IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName is null';
    ELSIF occurences IS NULL THEN
      RAISE EXCEPTION 'occurences is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSE
      query = 'SELECT (SELECT COUNT(*) FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ' WHERE ' || (TT_TableColumnNames(lookupSchemaName, lookupTableName))[1] || ' = ' || quote_literal(val) || ') = ' || occurences || ';';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsOccurence(
  val int,
  lookupSchemaName name,
  lookupTableName name,
  occurences int
)
RETURNS boolean AS $$
  SELECT TT_IsOccurence(val::double precision,lookupSchemaName,lookupTableName,occurences)
$$ LANGUAGE sql VOLATILE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsOccurence (list version)
--
-- val text/double precision/int - column to test.
-- occurences - int
-- lst text/double precision/int[]
--
-- if number of occurences of val in list equals occurences, return true.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsOccurence(
  val text,
  occurences int,
  VARIADIC lst text[]
)
RETURNS boolean AS $$
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSIF occurences IS NULL THEN
      RAISE EXCEPTION 'occurences is null';
    ELSE
      RETURN coalesce(array_length(array_positions(lst,val),1),0) = occurences;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsOccurence(
  val double precision,
  occurences int,
  VARIADIC lst double precision[]
)
RETURNS boolean AS $$
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSIF occurences IS NULL THEN
      RAISE EXCEPTION 'occurences is null';
    ELSE
      RETURN coalesce(array_length(array_positions(lst,val),1),0) = occurences;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsOccurence(
  val int,
  occurences int,
  VARIADIC lst int[]
)
RETURNS boolean AS $$
  SELECT TT_IsOccurence(val::double precision,occurences,VARIADIC lst::double precision[])
$$ LANGUAGE sql VOLATILE;


-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Match (table version)
--
-- val text/double precision/int - column to test.
-- lookupSchemaName name - schema name holding lookup table
-- lookupTableName name - lookup table
-- if val is present in first column of lookup table, returns TRUE.
------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_Match(text,name,name);
-- DROP FUNCTION IF EXISTS TT_Match(double precision,name,name);
-- DROP FUNCTION IF EXISTS TT_Match(integer,name,name);
CREATE OR REPLACE FUNCTION TT_Match(
  val text,
  lookupSchemaName name,
  lookupTableName name
)
RETURNS boolean AS $$
  DECLARE
    query text;
    return boolean;
  BEGIN
    IF lookupSchemaName IS NULL OR lookupTableName IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSE
      query = 'SELECT ' || quote_literal(val) || ' IN (SELECT ' || (TT_TableColumnNames(lookupSchemaName, lookupTableName))[1] || ' FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ');';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Match(
  val double precision,
  lookupSchemaName name,
  lookupTableName name
)
RETURNS boolean AS $$
  DECLARE
    query text;
    return boolean;
  BEGIN
    IF lookupSchemaName IS NULL OR lookupTableName IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName is null';
    ELSIF val IS NULL THEN
      RETURN FALSE;
    ELSE
      query = 'SELECT ' || val || ' IN (SELECT ' || (TT_TableColumnNames(lookupSchemaName, lookupTableName))[1] || ' FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ');';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Match(
  val int,
  lookupSchemaName name,
  lookupTableName name
)
RETURNS boolean AS $$
  SELECT TT_Match(val::double precision,lookupSchemaName,lookupTableName)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Match (list version) - does first argument match any of the following arguments?

--
-- val text/double precision/int - value to test.
-- lst text/double precision/int - list to test against
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Match(
  val text,
  VARIADIC lst text[]
)
RETURNS boolean AS $$
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN val = ANY(array_remove(lst, NULL));
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Match(
  val double precision,
  VARIADIC lst double precision[]
)
RETURNS boolean AS $$
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN val = ANY(array_remove(lst, NULL));
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Match(
  val integer,
  VARIADIC lst integer[]
)
RETURNS boolean AS $$
  SELECT TT_Match(val::double precision, VARIADIC lst::double precision[])
$$ LANGUAGE sql VOLATILE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_False
--
-- Return false
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_False()
RETURNS boolean AS $$
  BEGIN
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsString
--
-- Return TRUE if string (i.e. not numerics)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsString(
  val text
)
RETURNS boolean AS $$
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN TT_IsNumeric(val) IS FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsString(
  val double precision
)
RETURNS boolean AS $$
  SELECT TT_IsString(val::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsString(
  val int
)
RETURNS boolean AS $$
  SELECT TT_IsString(val::text)
$$ LANGUAGE sql VOLATILE;



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Begin Translation Function Definitions...
-- Translation functions return any kind of value (not only boolean).
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- TT_Copy
--
--  val text/boolean/double precision/int  - Value to return.
--
-- Return the value.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Copy(
  val text
)
RETURNS text AS $$
  BEGIN
    RETURN val;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Copy(
  val double precision
)
RETURNS double precision AS $$
  BEGIN
    RETURN val;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Copy(
  val int
)
RETURNS int AS $$
  SELECT TT_Copy(val::double precision)::int
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Copy(
  val boolean
)
RETURNS boolean AS $$
  SELECT TT_Copy(val::text)::boolean
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Concat
--
--  sep text  - Separator (e.g. '_'). If no sep required use '' as first argument.
--  var text[] - list of strings to concat
--
-- Return the value.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Concat(
  sep text,
  VARIADIC val text[]
)
RETURNS text AS $$
  BEGIN
    IF sep is NULL THEN
      RAISE EXCEPTION 'sep is null';
    ELSIF coalesce(array_position(val, NULL::text), 0) > 0 THEN -- with VARIADIC, STRICT only returns NULL if entire array returns NULL. So need to manually return NULL if a single array element is NULL.
      RAISE EXCEPTION 'val contains null';
    ELSE
      RETURN array_to_string(val, sep);
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Lookup
--
-- val text/double precision/int
-- lookupSchemaName
-- lookupTableName
-- lookupColumn
--
-- Return value from lookupColumn in lookupSchemaName.lookupTableName
-- that matches val in first column
-- If multiple val's, first row is returned
-- Error if any arguments are NULL
-- *Return value currently always text*
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Lookup(
  val text,
  lookupSchemaName name,
  lookupTableName name,
  lookupCol text
)
RETURNS text AS $$
  DECLARE
    query text;
    return text;
  BEGIN
    IF val IS NULL THEN
      RAISE EXCEPTION 'val is NULL';
    ELSIF lookupSchemaName IS NULL OR lookupTableName IS NULL OR lookupCol IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName or lookupCol is NULL';
    ELSE
      query = 'SELECT ' || lookupCol || ' FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ' WHERE ' || (TT_TableColumnNames(lookupSchemaName, lookupTableName))[1] || ' = ' || quote_literal(val) || ';';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Lookup(
  val double precision,
  lookupSchemaName name,
  lookupTableName name,
  lookupCol text
)
RETURNS text AS $$
  DECLARE
    query text;
    return text;
  BEGIN
    IF val IS NULL THEN
      RAISE EXCEPTION 'val is NULL';
    ELSIF lookupSchemaName IS NULL OR lookupTableName IS NULL OR lookupCol IS NULL THEN
      RAISE EXCEPTION 'lookupSchemaName or lookupTableName or lookupCol is NULL';
    ELSE
      query = 'SELECT ' || lookupCol || ' FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ' WHERE ' || (TT_TableColumnNames(lookupSchemaName, lookupTableName))[1] || ' = ' || quote_literal(val) || ';';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Lookup(
  val int,
  lookupSchemaName name,
  lookupTableName name,
  lookupCol text
)
RETURNS text AS $$
  SELECT TT_Lookup(val::double precision, lookupSchemaName, lookupTableName, lookupCol)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Length
--
-- val - values to test.
-- Count characters in string
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Length(
  val text
)
RETURNS int AS $$
  BEGIN
    IF val IS NULL THEN
      RAISE EXCEPTION 'val is NULL';
    ELSE
      RETURN char_length(val);
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Length(
  val double precision
)
RETURNS int AS $$
  SELECT TT_Length(val::text)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Length(
  val int
)
RETURNS int AS $$
  SELECT TT_Length(val::text)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Pad
--
-- val - string to pad.
-- target_length - total characters of output string
-- pad_char - character to pad with
--
-- pads if val shorter than target, trims if val longer than target
-- pad_char should always be a single character
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Pad(
  val text,
  target_length int,
  pad_char text DEFAULT 'x'
)
RETURNS text AS $$
  DECLARE
    val_length int;
    pad_length int;
  BEGIN
    IF val IS NULL OR target_length IS NULL OR pad_char IS NULL THEN
      RAISE EXCEPTION 'val or target_length or pad_char is NULL';
    ELSIF TT_Length(pad_char) != 1 THEN
      RAISE EXCEPTION 'pad_char length is not 1';
    ELSE
      val_length = TT_Length(val);
      pad_length = target_length - val_length;
      IF pad_length > 0 THEN
        RETURN TT_Concat('', repeat(pad_char,pad_length), val);
      ELSE
        RETURN substring(val from 1 for target_length);
      END IF;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Pad(
  val double precision,
  target_length int,
  pad_char text DEFAULT 'x'
)
RETURNS text AS $$
  SELECT TT_Pad(val::text, target_length, pad_char);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Pad(
  val int,
  target_length int,
  pad_char text DEFAULT 'x'
)
RETURNS text AS $$
  SELECT TT_Pad(val::text, target_length, pad_char);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Map   --   NOT WORKING
--
-- val text/double precision/int - values to test.
-- lst1 text/double precision/int - list containing vals
-- lst2 text/double precision/int - return values from this list that match vals
--
-- Return value from list in lookupSchemaName.lookupTableName
-- that matches val in first column
-- If multiple val's, first row is returned
-- Error if val is NULL

-- Can't convert this query into dynamic function:
-- SELECT (ARRAY['TA','TB','TC','TD'])[array_position(ARRAY['RA','RB','RC','RD'],'RD')];

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Map(
  val text,
  lst1 text[],
  lst2 text[]
)
RETURNS text AS $$
  DECLARE
    query text;
    return text;
  BEGIN
    IF val IS NULL THEN
      RAISE EXCEPTION 'val is NULL';
    ELSIF coalesce(array_position(lst1, NULL::text), 0) > 0 OR coalesce(array_position(lst2, NULL::text), 0) > 0 THEN
      RAISE EXCEPTION 'lst1 or lst2 contain NULLs';
    ELSE
      query = 'SELECT (' || quote_literal(lst1) || ')[array_position(' || quote_literal(lst2) || ', ' || quote_literal(val) || ')];';
      RAISE NOTICE '11 query = %',query;
      EXECUTE query INTO  return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;