-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION psql_temporal" to load this file. \quit

-- Create range type (custom type)? Optional
-- Create operators (AS OF<date_time>, FROM<start_date_time>TO<end_date_time>, 
--   BETWEEN<start_date_time>AND<end_date_time>, CONTAINED IN (<start_date_time> , <end_date_time>))
-- Convert table to temporal
-- Create history table
-- Create view to get current status

-- Function to create string to append to update trigger. If update_columns is empty, do all, otherwise, only do the columns in the array.
CREATE OR REPLACE FUNCTION public._temporal_get_update_of_columns(update_columns text[])
RETURNS text
LANGUAGE plpgsql VOLATILE
  AS $get_update_of_columns$
  BEGIN
    -- everything
    if(array_length(update_columns,1) > 0 ) then
      return 'OF ' || array_to_string(update_columns, ',');
     else
      return '';
    end if;

  END;
  $get_update_of_columns$;
  
CREATE OR REPLACE FUNCTION public.convert_to_temporal(table_name regclass,update_columns text[] DEFAULT '{}')
RETURNS boolean
LANGUAGE plpgsql VOLATILE
  AS $$
    -- DECLARE
    --   chars char[];
    --   ret varchar;
    --   val int;
    BEGIN

    -- add sys temporal tables
    EXECUTE format('
      ALTER TABLE %I
      ADD COLUMN SysStartTime timestamptz DEFAULT NOW(), 
      ADD COLUMN SysEndTime timestamptz;
      ',table_name);
    -- add application temporal tables
    EXECUTE format('
      ALTER TABLE %I
      ADD COLUMN ApplicationStartTime timestamptz, 
      ADD COLUMN ApplicationEndTime timestamptz;
      ',table_name);

    -- create the table, neat thing is primary key is dropped
	  EXECUTE format('
      CREATE TABLE IF NOT EXISTS temporal_%I_history as TABLE %I ;', table_name,table_name);
    -- create tiggers to update table system temporal tables

    EXECUTE format('
      DROP TRIGGER IF EXISTS %1$s_TEMPORAL_TRIGGER ON PUBLIC.%1$s;

      CREATE OR REPLACE FUNCTION %1$s_INSERT_INTO_HISTORY() 
      RETURNS TRIGGER 
      LANGUAGE PLPGSQL 
      AS 
      $%1$s_INSERT_INTO_HISTORY$
      DECLARE
        update_time timestamptz = now();
      BEGIN
        -- update old record
        UPDATE temporal_%1$s_history history
        SET SysEndTime = update_time
        WHERE OLD.id=history.id and SysEndTime IS NULL;

        -- update starttime of new
        UPDATE temporal_%1$s_history history
        SET SysStartTime = update_time
        WHERE NEW.id=history.id and SysEndTime IS NULL;

        NEW.SysStartTime := update_time;

        -- if delete, dont insert new record in history.
        IF (TG_OP <> ''DELETE'') THEN
          INSERT INTO temporal_%1$s_history VALUES (NEW.*);
        END IF;
        RETURN NEW;
      END;
      $%1$s_INSERT_INTO_HISTORY$;

      CREATE TRIGGER %1$s_UPDATE_TEMPORAL_TRIGGER AFTER
      UPDATE ' || _temporal_get_update_of_columns(update_columns) || ' ON %1$s
      FOR EACH ROW
      WHEN (OLD.* IS DISTINCT FROM NEW.*)
      EXECUTE PROCEDURE %1$s_INSERT_INTO_HISTORY();

      CREATE TRIGGER %1$s_INSERT_DELETE_TEMPORAL_TRIGGER AFTER
      INSERT OR DELETE ON %1$s
      FOR EACH ROW
      EXECUTE PROCEDURE %1$s_INSERT_INTO_HISTORY();

    ',table_name);
    -- as of functions.
    EXECUTE format('
      CREATE OR REPLACE FUNCTION %1$s_AS_OF(_time timestamptz) 
      RETURNS SETOF temporal_%1$s_history
      LANGUAGE PLPGSQL 
      AS 
      $%1$s_AS_OF$
      BEGIN
        return query
          select * 
          from temporal_%1$s_history
          where (SysEndTime >= _time or SysEndTime IS NULL) and SysStartTime <= _time;
      END;
      $%1$s_AS_OF$
    ',table_name);
    RETURN(true);
    END;
  $$;