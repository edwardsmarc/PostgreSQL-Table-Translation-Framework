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
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Begin Validation Function Definitions...
-- Validation functions return only boolean values (TRUE or FALSE).
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- TT_NotNull
--
--  var[] text/boolean/double precision/int  - List of values to test.
--
-- Return TRUE if vals are not NULL.
-- Return FALSE if any vals are NULL.
-- e.g. TT_NotNull('a', 'b', 'c')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotNull(
  VARIADIC val text[]
)
RETURNS boolean AS $$
  BEGIN
    RETURN coalesce(array_position(val, NULL::text), 0) = 0;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_NotNull(
  VARIADIC val double precision[]
)
RETURNS boolean AS $$
  BEGIN
    RETURN coalesce(array_position(val, NULL::double precision), 0) = 0;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_NotNull(
  VARIADIC val boolean[]
)
RETURNS boolean AS $$
  SELECT TT_NotNull(VARIADIC val::text[]);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_NotNull(
  VARIADIC val int[]
)
RETURNS boolean AS $$
  SELECT TT_NotNull(VARIADIC val::double precision[]);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_NotEmpty
--
--  val text  - list of values to test
--
-- Return TRUE if vals are not an empty string.
-- Return FALSE if any val is empty string or padded spaces (e.g. '' or '  ') or Null.
-- e.g. TT_NotEmpty('a', 'b', 'c')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_NotEmpty(
   VARIADIC val text[]
)
RETURNS boolean AS $$
  DECLARE
  BEGIN
    IF coalesce(array_position(val, NULL::text), 0) > 0 THEN
      RETURN FALSE;
    ELSE
      RETURN bool_and(TRIM(x) != '') FROM unnest(val) AS x;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE; 
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsInt
--
--  val double precision/int/text - List of values to test.
--
--  Do all values represent integers? Can be of type int, double precision or text (e.g. 1, 1.0, '1', '1.0')
--  Null values return FALSE
--  Strings with numeric characters and '.' will be passed to IsInt
--  Strings with anything else (e.g. letter characters) return FALSE.
--  e.g. TT_IsInt(1,2,3,4,5)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsInt(
   VARIADIC val double precision[]
)
RETURNS boolean AS $$
  BEGIN
    IF coalesce(array_position(val, NULL::double precision), 0) > 0 THEN
      RETURN FALSE;
    ELSE
      RETURN bool_and(x - x::int = 0) FROM unnest(val) AS x;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsInt(
   VARIADIC val int[]
)
RETURNS boolean AS $$
  SELECT TT_IsInt(VARIADIC val::double precision[]);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsInt(
   VARIADIC val text[]
)
RETURNS boolean AS $$
  DECLARE
    x double precision[];
  BEGIN
    x = val::double precision[];
    RETURN TT_IsInt(VARIADIC val::double precision[]);
  EXCEPTION WHEN OTHERS THEN
      RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsNumeric
--
--  val double precision/int/text - List of values to test.
--
--  Can all values be cast to double precision? (e.g. 1.1, 1, '1.5')
--  Null values return FALSE
--  e.g. TT_IsNumeric('1.1', '1.2', '1.3')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsNumeric(
   VARIADIC val text[]
)
  RETURNS boolean AS $$
    DECLARE
      x double precision[];
    BEGIN
      IF coalesce(array_position(val, NULL::text), 0) > 0 THEN
        RETURN FALSE;
      ELSE
        x = val::double precision[];
        RETURN TRUE;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      RETURN FALSE;
    END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsNumeric(
   VARIADIC val int[]
)
RETURNS boolean AS $$
  SELECT TT_IsNumeric(VARIADIC val::text[])
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsNumeric(
   VARIADIC val double precision[]
)
RETURNS boolean AS $$
  SELECT TT_IsNumeric(VARIADIC val::text[])
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
-- e.g. TT_Between(5, 0, 100)
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
      RETURN val >= min and val <= max;
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

CREATE OR REPLACE FUNCTION TT_Between(
  val text,
  min double precision,
  max double precision
)
RETURNS boolean AS $$
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    END IF;
    IF TT_TypeGuess(val) = 'text' THEN
     RAISE EXCEPTION 'val is type text';
    END IF;
    RETURN TT_Between(val::double precision, min, max);
    END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Between(
  val int,
  min double precision,
  max text
)
RETURNS boolean AS $$
  BEGIN
    IF TT_TypeGuess(max) = 'text' THEN
      RAISE EXCEPTION 'max is type text';
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Between(
  val int,
  min text,
  max double precision
)
RETURNS boolean AS $$
  BEGIN
    IF TT_TypeGuess(min) = 'text' THEN
      RAISE EXCEPTION 'min is type text';
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Between(
  val text,
  min double precision,
  max text
)
RETURNS boolean AS $$
  BEGIN
    IF TT_TypeGuess(val) = 'text' OR TT_TypeGuess(max) = 'text' THEN
      RAISE EXCEPTION 'val and max is type text';
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Between(
  val text,
  min text,
  max double precision
)
RETURNS boolean AS $$
  BEGIN
    IF TT_TypeGuess(val) = 'text' OR TT_TypeGuess(min)= 'text' THEN
      RAISE EXCEPTION 'val and min is type text';
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GreaterThan
--
--  val double precision/int - Value to test.
--  lowerBound double precision - lower bound to test against.
--  inclusive boolean - is lower bound inclusive? Default True.
--
--  Return TRUE if val >= lowerBound and inclusive = TRUE.
--  Return TRUE if val > lowerBound and inclusive = FALSE.
--  Return FALSE otherwise.
--  Return FALSE if val is NULL.
--  Return error if lowerBound or inclusive are null.
--  e.g. TT_GreaterThan(5, 0, TRUE)
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
--  upperBound double precision - upper bound to test against.
--  inclusive boolean - is upper bound inclusive? Default True.
--
--  Return TRUE if val <= upperBound and inclusive = TRUE.
--  Return TRUE if val < upperBound and inclusive = FALSE.
--  Return FALSE otherwise.
--  Return FALSE if val is NULL.
--  Return error if upperBound or inclusive are null.
--  e.g. TT_LessThan(1, 5, TRUE)
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
-- TT_HasUniqueValues
--
-- val text/double precision/int - val to test.
-- lookupSchemaName name - schema name holding lookup table.
-- lookupTableName name - lookup table.
-- occurences - int defaults to 1
--
-- if number of occurences of val in source_val of schema.table equals occurences, return true.
-- e.g. TT_HasUniqueValues('BS', 'public', 'bc08', 1)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_HasUniqueValues(
  val text,
  lookupSchemaName name,
  lookupTableName name,
  occurences int DEFAULT 1
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
      query = 'SELECT (SELECT COUNT(*) FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ' WHERE source_val = ' || quote_literal(val) || ') = ' || occurences || ';';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_HasUniqueValues(
  val double precision,
  lookupSchemaName name,
  lookupTableName name,
  occurences int DEFAULT 1
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
      query = 'SELECT (SELECT COUNT(*) FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ' WHERE source_val = ' || quote_literal(val) || ') = ' || occurences || ';';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_HasUniqueValues(
  val int,
  lookupSchemaName name,
  lookupTableName name,
  occurences int
)
RETURNS boolean AS $$
  SELECT TT_HasUniqueValues(val::double precision,lookupSchemaName,lookupTableName,occurences)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Match (table version)
--
-- val text/double precision/int - column to test.
-- lookupSchemaName name - schema name holding lookup table.
-- lookupTableName name - lookup table.
-- ignoreCase - default TRUE. Should upper/lower case be ignored?
--
-- if val is present in source_val of schema.lookup table, returns TRUE.
-- e.g. TT_Match('BS', 'public', 'bc08', TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Match(
  val text,
  lookupSchemaName name,
  lookupTableName name,
  ignoreCase boolean DEFAULT TRUE
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
    ELSIF ignoreCase = FALSE THEN
      query = 'SELECT ' || quote_literal(val) || ' IN (SELECT source_val FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ');';
      EXECUTE query INTO return;
      RETURN return;
    ELSE
      query = 'SELECT ' || quote_literal(upper(val)) || ' IN (SELECT upper(source_val) FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ');';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Match(
  val double precision,
  lookupSchemaName name,
  lookupTableName name,
  ignoreCase boolean DEFAULT TRUE
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
  lookupTableName name,
  ignoreCase boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  SELECT TT_Match(val::double precision,lookupSchemaName,lookupTableName,ignoreCase)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Match (list version)
--
-- val text/double precision/int - value to test.
-- lst text - string containing comma separated vals.
--
-- Is val in lst?
-- val followed by string of test values
-- e.g. TT_Match('a', 'a,b,c')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Match(
  val text,
  lst text,
  ignoreCase boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  DECLARE
    var1 text[];
  BEGIN
    IF val IS NULL THEN
      RETURN FALSE;
    ELSIF ignoreCase = FALSE THEN
      var1 = string_to_array(lst, ',');
      RETURN val = ANY(array_remove(var1, NULL));
    ELSE
      var1 = string_to_array(upper(lst), ',');
      RETURN upper(val) = ANY(array_remove(var1, NULL));
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Match(
  val double precision,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_Match(val::text, lst)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Match(
  val integer,
  lst text
)
RETURNS boolean AS $$
  SELECT TT_Match(val::text, lst)
$$ LANGUAGE sql VOLATILE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_False
--
-- Return false
-- e.g. TT_False()
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
-- Return TRUE if all vals are strings (i.e. not numeric)
-- e.g. TT_IsString('a', 'b', 'c')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_IsString(
  VARIADIC val text[]
)
RETURNS boolean AS $$
  BEGIN
    IF coalesce(array_position(val, NULL::text), 0) > 0 THEN
      RETURN FALSE;
    ELSE
      RETURN TT_IsNumeric(VARIADIC val) IS FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsString(
  VARIADIC val double precision[]
)
RETURNS boolean AS $$
  SELECT TT_IsString(VARIADIC val::text[])
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_IsString(
  VARIADIC val int[]
)
RETURNS boolean AS $$
  SELECT TT_IsString(VARIADIC val::text[])
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
--  processNulls - if true, concat is run and nulls ignored. If false, nulls raise error.
--  var text[] - list of strings to concat
--
-- Return the value.
-- e.g. TT_Concat('_', FALSE, 'a', 'b', 'c'))
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Concat(
  sep text,
  processNulls boolean,
  VARIADIC val text[]
)
RETURNS text AS $$
  BEGIN
    IF sep is NULL THEN
      RAISE EXCEPTION 'sep is null';
    ELSIF coalesce(array_position(val, NULL::text), 0) > 0 AND processNulls = FALSE THEN -- test if any list elements are null
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
-- val text/double precision/int - val to lookup
-- lookupSchemaName - schema name containing lookup table
-- lookupTableName - lookup table name
-- lookupColumn - column to return
-- ignoreCase - default TRUE. Should upper/lower case be ignored?
--
-- Return value from lookupColumn in lookupSchemaName.lookupTableName
-- that matches val in source_val column.
-- If multiple matches, first row is returned.
-- Error if any arguments are NULL.
-- *Return value currently always text*
-- e.g. TT_Lookup('BS', 'public', 'bc08', 'species1', TRUE)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Lookup(
  val text,
  lookupSchemaName name,
  lookupTableName name,
  lookupCol text,
  ignoreCase boolean DEFAULT TRUE
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
    ELSIF ignoreCase = FALSE THEN
      query = 'SELECT ' || lookupCol || ' FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ' WHERE source_val = ' || quote_literal(val) || ';';
      EXECUTE query INTO return;
      RETURN return;
    ELSE
      query = 'SELECT ' || lookupCol || ' FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ' WHERE upper(source_val) = upper(' || quote_literal(val) || ');';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Lookup(
  val double precision,
  lookupSchemaName name,
  lookupTableName name,
  lookupCol text,
  ignoreCase boolean DEFAULT TRUE
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
      query = 'SELECT ' || lookupCol || ' FROM ' || TT_FullTableName(lookupSchemaName, lookupTableName) || ' WHERE source_val = ' || quote_literal(val) || ';';
      EXECUTE query INTO return;
      RETURN return;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Lookup(
  val int,
  lookupSchemaName name,
  lookupTableName name,
  lookupCol text,
  ignoreCase boolean DEFAULT TRUE
)
RETURNS text AS $$
  SELECT TT_Lookup(val::double precision, lookupSchemaName, lookupTableName, lookupCol, ignoreCase)
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Length
--
-- val - values to test.
--
-- Count characters in string
-- e.g. TT_Length('12345')
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
-- targetLength - total characters of output string.
-- padChar - character to pad with - Defaults to 'x'.
--
-- Pads if val shorter than target, trims if val longer than target.
-- padChar should always be a single character.
-- e.g. TT_Pad('tab1', 10, 'x')
------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Pad(
  val text,
  targetLength int,
  padChar text DEFAULT 'x'
)
RETURNS text AS $$
  DECLARE
    val_length int;
    pad_length int;
  BEGIN
    IF val IS NULL OR targetLength IS NULL OR padChar IS NULL THEN
      RAISE EXCEPTION 'val or targetLength or padChar is NULL';
    ELSIF TT_Length(padChar) != 1 THEN
      RAISE EXCEPTION 'padChar length is not 1';
    ELSE
      val_length = TT_Length(val);
      pad_length = targetLength - val_length;
      IF pad_length > 0 THEN
        RETURN TT_Concat('', FALSE, repeat(padChar,pad_length), val);
      ELSE
        RETURN substring(val from 1 for targetLength);
      END IF;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Pad(
  val double precision,
  targetLength int,
  padChar text DEFAULT 'x'
)
RETURNS text AS $$
  SELECT TT_Pad(val::text, targetLength, padChar);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Pad(
  val int,
  targetLength int,
  padChar text DEFAULT 'x'
)
RETURNS text AS $$
  SELECT TT_Pad(val::text, targetLength, padChar);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_Map
--
-- val text/double precision/int - value to test.
-- lst1 text/double precision/int - string containing comma seperated vals
-- lst2 text/double precision/int - string containing comma seperated vals
-- ignoreCase - default TRUE. Should upper/lower case be ignored?
--
-- Return value from lst2 that matches value index in lst1
-- Error if val is NULL
-- e.g. TT_Map('A','A,B,C','1,2,3', TRUE)

------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_Map(
  val text,
  lst1 text,
  lst2 text,
  ignoreCase boolean DEFAULT TRUE
)
RETURNS text AS $$
  DECLARE
    var1 text[];
    var2 text[];
  BEGIN
    IF val IS NULL THEN
      RAISE EXCEPTION 'val is NULL';
    ELSIF ignoreCase = FALSE THEN
      var1 = string_to_array(lst1, ',');
      var2 = string_to_array(lst2, ',');
      RETURN (var2)[array_position(var1,val)];
    ELSE
      var1 = string_to_array(upper(lst1), ',');
      var2 = string_to_array(upper(lst2), ',');
      RETURN (var2)[array_position(var1,upper(val))];
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Map(
  val double precision,
  lst1 text,
  lst2 text
)
RETURNS text AS $$
  SELECT TT_Map(val::text,lst1,lst2)
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION TT_Map(
  val int,
  lst1 text,
  lst2 text
)
RETURNS text AS $$
  SELECT TT_Map(val::text,lst1,lst2)
$$ LANGUAGE sql VOLATILE;
