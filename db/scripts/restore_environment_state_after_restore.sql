-- Replace production operational state from the restored dump with the values
-- captured from this environment before the restore began.
DO $$
BEGIN
  TRUNCATE public.feature_flag_state;
  INSERT INTO public.feature_flag_state (
    name,
    active,
    created_at,
    updated_at,
    legacy_redis_synced_at
  )
    SELECT name, active, created_at, updated_at, legacy_redis_synced_at
    FROM pg_temp.preserved_feature_flag_state;
EXCEPTION
  WHEN undefined_table OR undefined_column THEN NULL;
END $$;

DO $$
BEGIN
  TRUNCATE public.site_setting;
  INSERT INTO public.site_setting (
    name,
    value,
    created_at,
    updated_at,
    legacy_redis_synced_at
  )
    SELECT name, value, created_at, updated_at, legacy_redis_synced_at
    FROM pg_temp.preserved_site_setting;
EXCEPTION
  WHEN undefined_table OR undefined_column THEN NULL;
END $$;
