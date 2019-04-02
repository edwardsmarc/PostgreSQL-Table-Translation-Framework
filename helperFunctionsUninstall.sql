﻿------------------------------------------------------------------------------
-- PostgreSQL Table Tranlation Engine - Helper functions uninstallation file
-- Version 0.1 for PostgreSQL 9.x
-- https://github.com/edwardsmarc/postTranslationEngine
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2020 Pierre Racine <pierre.racine@sbf.ulaval.ca>, 
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
-------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_NotNull(text);
DROP FUNCTION IF EXISTS TT_Between(text, double precision, double precision);
DROP FUNCTION IF EXISTS TT_NotEmpty(text);
DROP FUNCTION IF EXISTS TT_GreaterThan(text, double precision, boolean);
DROP FUNCTION IF EXISTS TT_LessThan(text, double precision, boolean);
DROP FUNCTION IF EXISTS TT_IsInt(text[]);
DROP FUNCTION IF EXISTS TT_IsNumeric(text[]);

DROP FUNCTION IF EXISTS TT_Match(text,text,boolean);
DROP FUNCTION IF EXISTS TT_Match(int,text);
DROP FUNCTION IF EXISTS TT_Match(double precision,text);
DROP FUNCTION IF EXISTS TT_Match(text, name, name, boolean);
DROP FUNCTION IF EXISTS TT_Match(double precision, name, name, boolean);
DROP FUNCTION IF EXISTS TT_Match(integer, name, name, boolean);
DROP FUNCTION IF EXISTS TT_Concat(text,boolean,text[]);
DROP FUNCTION IF EXISTS TT_IsError(text);
DROP FUNCTION IF EXISTS TT_Copy(text);
DROP FUNCTION IF EXISTS TT_Copy(double precision);
DROP FUNCTION IF EXISTS TT_Copy(int);
DROP FUNCTION IF EXISTS TT_Copy(boolean);
DROP FUNCTION IF EXISTS TT_Lookup(text,name,name,text,boolean);
DROP FUNCTION IF EXISTS TT_Lookup(double precision,name,name,text,boolean);
DROP FUNCTION IF EXISTS TT_Lookup(int,name,name,text,boolean);
DROP FUNCTION IF EXISTS TT_Map(text,text,text,boolean);
DROP FUNCTION IF EXISTS TT_Map(double precision,text,text);
DROP FUNCTION IF EXISTS TT_Map(int,text,text);
DROP FUNCTION IF EXISTS TT_False();
DROP FUNCTION IF EXISTS TT_IsString(text[]);
DROP FUNCTION IF EXISTS TT_IsString(double precision[]);
DROP FUNCTION IF EXISTS TT_IsString(int[]);
DROP FUNCTION IF EXISTS TT_Length(text);
DROP FUNCTION IF EXISTS TT_Length(double precision);
DROP FUNCTION IF EXISTS TT_Length(int);
DROP FUNCTION IF EXISTS TT_Pad(text,int,text);
DROP FUNCTION IF EXISTS TT_Pad(double precision,int,text);
DROP FUNCTION IF EXISTS TT_Pad(int,int,text);
DROP FUNCTION IF EXISTS TT_HasUniqueValues(text,name,name,int);
DROP FUNCTION IF EXISTS TT_HasUniqueValues(double precision,name,name,int);
DROP FUNCTION IF EXISTS TT_HasUniqueValues(int,name,name,int);