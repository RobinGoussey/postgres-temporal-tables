-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION psql_temporal" to load this file. \quit

-- Create range type (custom type)? Optional
-- Create operators (AS OF<date_time>, FROM<start_date_time>TO<end_date_time>, 
--   BETWEEN<start_date_time>AND<end_date_time>, CONTAINED IN (<start_date_time> , <end_date_time>))
-- Convert table to temporal
-- Create history table
-- Create view to get current status


-- CREATE OR REPLACE FUNCTION create_history_trigger(table_name regclass)
-- LANGUAGE plpgsql IMMUTABLE STRICT
--   AS $$
-- execute FORMAT('
-- CREATE OR REPLACE FUNCTION %I_insert_into_history() 
--    RETURNS TRIGGER 
--    LANGUAGE PLPGSQL
-- AS $$
-- DECLARE 
--   timestamptz update_time = now();
-- END;

-- BEGIN
--    -- trigger logic
--   UPDATE %I_history history
--   SET SysEndTime = update_time
--   WHERE OLD.id=history.id and SysEndTime IS NULL;
  
--   INSERT INTO %I_history VALUES NEW;
-- END;
-- $$',table_name,table_name,table_name)
--     END;
--   $$;

CREATE OR REPLACE FUNCTION public.convert_to_temporal(table_name regclass)
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

        -- if delete, dont insert new record in history.
        IF (TG_OP <> ''DELETE'') THEN
          INSERT INTO temporal_%1$s_history VALUES (NEW.*);
        END IF;
        RETURN NEW;
      END;
      $%1$s_INSERT_INTO_HISTORY$;

      CREATE TRIGGER %1$s_UPDATE_TEMPORAL_TRIGGER AFTER
      UPDATE OR INSERT OR DELETE ON %1$s
      FOR EACH ROW EXECUTE PROCEDURE %1$s_INSERT_INTO_HISTORY();

    ',table_name);
    -- EXECUTE format('
    -- CREATE TRIGGER %I_update
    -- AFTER UPDATE ON %I
    -- FOR ROW
    --   EXECUTE PROCEDURE trigger_function;
    --   ',table_name);   


    -- EXECUTE format('
    -- CREATE TRIGGER %I_update
    -- AFTER UPDATE ON %I
    -- FOR EACH ROW
    -- UPDATE %I SET 
    -- EXECUTE PROCEDURE log_account_update();
    --   ',table_name);



    RETURN(true);
    END;
  $$;



-- CREATE FUNCTION create_temporal_table(table_name text)
-- RETURNS boolean
-- LANGUAGE plpgsql IMMUTABLE STRICT
--   AS $$
--     DECLARE
--       chars char[];
--       ret varchar;
--       val int;
--     BEGIN
-- 	  -- create the table
-- 	  EXECUTE format('
--       CREATE TABLE IF NOT EXISTS %I as TABLE _tbl 
-- 	  WITH NO DATA;', 't_' || table_name);

--     RETURN(ret);
--     END;
--   $$;


-- working, todo replace %I

-- DROP TRIGGER IF EXISTS FIREMEN_UPDATE on public.firemen_temporal;

-- CREATE OR REPLACE FUNCTION firemen_temporal_insert_into_history() 
--    RETURNS TRIGGER 
--    LANGUAGE PLPGSQL
-- AS $$
-- DECLARE 
--   update_time timestamptz = now();
-- BEGIN
--    -- trigger logic
--   UPDATE firemen_temporal_history history
--   SET SysEndTime = update_time
--   WHERE OLD.id=history.id and SysEndTime IS NULL;
  
--   INSERT INTO firemen_temporal_history VALUES (NEW.*);
--   RETURN NEW;
-- END;
-- $$;

-- CREATE TRIGGER FIREMEN_UPDATE
--     AFTER UPDATE ON firemen_temporal
--     FOR ROW
--       EXECUTE PROCEDURE firemen_temporal_insert_into_history();
	  
-- UPDATE firemen_temporal
-- SET name = 'Bert';