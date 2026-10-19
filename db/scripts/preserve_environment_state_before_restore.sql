-- Database restores copy production data into QA, staging and review apps.
-- Keep operational state environment-specific by holding it in temporary
-- tables for the duration of the restore transaction.
-- The advisory lock matches LegacyRedisState::ADVISORY_LOCK_KEY. The table
-- locks also exclude writes from releases that predate that coordination.
-- Only undefined_table is swallowed (tables may not exist yet). A dropped or
-- renamed column must raise so the restore fails loudly instead of quietly
-- keeping production flags.
SELECT pg_advisory_xact_lock(20261015, 6581);

DO $$
BEGIN
  LOCK TABLE public.feature_flag_state, public.site_setting
    IN ACCESS EXCLUSIVE MODE;
EXCEPTION
  WHEN undefined_table THEN NULL;
END $$;

CREATE TEMP TABLE preserved_feature_flag_state (
  name varchar NOT NULL,
  active boolean NOT NULL,
  created_at timestamp(6) without time zone NOT NULL,
  updated_at timestamp(6) without time zone NOT NULL,
  legacy_redis_synced_at timestamp(6) without time zone
) ON COMMIT DROP;

CREATE TEMP TABLE preserved_site_setting (
  name varchar NOT NULL,
  value varchar NOT NULL,
  created_at timestamp(6) without time zone NOT NULL,
  updated_at timestamp(6) without time zone NOT NULL,
  legacy_redis_synced_at timestamp(6) without time zone
) ON COMMIT DROP;

DO $$
BEGIN
  INSERT INTO pg_temp.preserved_feature_flag_state
    SELECT name, active, created_at, updated_at, legacy_redis_synced_at
    FROM public.feature_flag_state;
EXCEPTION
  WHEN undefined_table THEN NULL;
END $$;

DO $$
BEGIN
  INSERT INTO pg_temp.preserved_site_setting
    SELECT name, value, created_at, updated_at, legacy_redis_synced_at
    FROM public.site_setting;
EXCEPTION
  WHEN undefined_table THEN NULL;
END $$;
