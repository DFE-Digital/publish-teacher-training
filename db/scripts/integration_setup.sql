INSERT INTO "user" (email,
                    first_name,
                    last_name,
                    state,
                    accept_terms_date_utc,
                    admin)
            VALUES ('becomingateacher+admin-integration-tests@digital.education.gov.uk',
                    'admin',
                    'admin',
                    'transitioned',
                    current_timestamp,
                    true)
            ON CONFLICT (email) DO nothing;

INSERT INTO "user" (email,
                    first_name,
                    last_name,
                    state,
                    accept_terms_date_utc)
            VALUES ('becomingateacher+integration-tests@digital.education.gov.uk',
                    'integration',
                    'tests',
                    'transitioned',
                    current_timestamp)
            ON CONFLICT (email) DO nothing;

INSERT INTO "provider" (provider_code,
                        provider_name,
                        recruitment_cycle_id,
                        provider_type,
                        accredited)
            VALUES ('B1T',
                    'bat 1',
                    (SELECT id FROM "recruitment_cycle"
                               ORDER BY year DESC limit 1),
                    'O',
                    true)
            ON CONFLICT (provider_code, recruitment_cycle_id) DO nothing;

INSERT INTO "organisation"
            (name)
            (SELECT 'Borg'
                    WHERE NOT EXISTS (SELECT id FROM "organisation"
                                             WHERE name = 'Borg'));

INSERT INTO "organisation_provider"
            (provider_id, organisation_id)
            (SELECT
                (SELECT id
                       FROM "provider"
                       WHERE provider_code = 'B1T'
                             AND recruitment_cycle_id = (
                                 SELECT id
                                        FROM "recruitment_cycle"
                                        ORDER BY year DESC limit 1)),
                (SELECT id FROM organisation WHERE name = 'Borg')
       WHERE NOT EXISTS (SELECT *
                                FROM "organisation_provider"
                                WHERE provider_id=(
                                      SELECT id
                                             FROM "provider"
                                             WHERE provider_code = 'B1T'
                                                   AND recruitment_cycle_id = (
                                                       SELECT id
                                                              FROM "recruitment_cycle"
                                                              ORDER BY year DESC limit 1))
                                      AND organisation_id = (
                                          SELECT id
                                                 FROM "organisation"
                                                 WHERE name = 'Borg')));

INSERT INTO "organisation_user" (user_id, organisation_id)
            SELECT
              (SELECT id
                      FROM "user"
                      WHERE email = 'becomingateacher+integration-tests@digital.education.gov.uk'),
              (SELECT id FROM "organisation" WHERE name = 'Borg')
              ON CONFLICT (user_id, organisation_id) DO nothing;

INSERT INTO "organisation_user"
            (user_id, organisation_id)
            SELECT id,
                   (SELECT id
                           FROM "organisation"
                           WHERE name = 'Borg')
                   FROM "user"
                   WHERE admin = TRUE
                   ON CONFLICT (user_id, organisation_id) DO nothing;

-- Persona users for signing in to lower environments (see
-- app/views/publish/authentication/personas/index.html.erb). Each persona
-- gets access to its providers in the two latest cycles, so it works in the
-- current cycle and in the next cycle during rollover.
INSERT INTO "user" (email,
                    first_name,
                    last_name,
                    state,
                    accept_terms_date_utc)
            VALUES ('persona-anne@example.org',
                    'Course administrator',
                    'Anne',
                    'transitioned',
                    current_timestamp),
                   ('persona-susy@example.org',
                    'ITT partnership manager',
                    'Susy',
                    'transitioned',
                    current_timestamp),
                   ('persona-mary@example.org',
                    'Multi-org administrator',
                    'Mary',
                    'transitioned',
                    current_timestamp)
            ON CONFLICT (email) DO nothing;

INSERT INTO "user_permission" (user_id, provider_id, created_at, updated_at)
            SELECT "user".id, provider.id, current_timestamp, current_timestamp
                   FROM (VALUES ('persona-anne@example.org', '26J'),
                                ('persona-susy@example.org', 'K30'),
                                ('persona-mary@example.org', 'S14'),
                                ('persona-mary@example.org', '1GT'),
                                ('persona-mary@example.org', '1JM'),
                                ('persona-mary@example.org', '1MH'),
                                ('persona-mary@example.org', '1VQ'))
                        AS persona (email, provider_code)
                   JOIN "user" ON "user".email = persona.email
                   JOIN "provider" ON provider.provider_code = persona.provider_code
                   WHERE provider.discarded_at IS NULL
                         AND provider.recruitment_cycle_id IN (
                             SELECT id FROM "recruitment_cycle"
                                    ORDER BY year DESC limit 2)
            ON CONFLICT (user_id, provider_id) DO nothing;
