DELETE FROM session;
DELETE FROM audit;

-- Solid Cache blobs are opaque (keys can include postcodes/addresses).
-- Skip if the dump predates the solid_cache_entries migration.
-- TRUNCATE rather than DELETE: after cutover this table can grow toward the 1GB cap.
DO $$
BEGIN
  TRUNCATE solid_cache_entries;
EXCEPTION
  WHEN undefined_table THEN NULL;
END $$;

-- Solid Queue rows can hold job arguments, failure errors and batch callbacks
-- with personal or sensitive data. Truncate every operational table; list them
-- together so foreign keys do not block. Skip if the dump predates the migration.
DO $$
BEGIN
  TRUNCATE
    solid_queue_blocked_executions,
    solid_queue_claimed_executions,
    solid_queue_failed_executions,
    solid_queue_ready_executions,
    solid_queue_recurring_executions,
    solid_queue_scheduled_executions,
    solid_queue_batch_executions,
    solid_queue_jobs,
    solid_queue_batches,
    solid_queue_pauses,
    solid_queue_processes,
    solid_queue_recurring_tasks,
    solid_queue_semaphores;
EXCEPTION
  WHEN undefined_table THEN NULL;
END $$;

UPDATE "user"
       SET email=concat('anonimized-user-',id,'@example.org'),
           first_name='anon',
           last_name='anon',
           sign_in_user_id=null
       WHERE email NOT LIKE '%@digital.education.gov.uk'
             AND email NOT LIKE '%@education.gov.uk';

UPDATE "candidate"
       SET email_address=concat('anonimized-candidate-',id,'@example.com')
       WHERE email_address NOT LIKE '%@digital.education.gov.uk'
             AND email_address NOT LIKE '%@education.gov.uk';

UPDATE "providers_onboarding_form_request"
       SET email_address=concat('anonimized-user-',id,'@example.org'),
           first_name='anon',
           last_name='anon'
        WHERE email_address NOT LIKE '%@digital.education.gov.uk'
             AND email_address NOT LIKE '%@education.gov.uk';
