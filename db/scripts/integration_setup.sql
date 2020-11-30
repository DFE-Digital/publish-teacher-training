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
                        scheme_member,
                        provider_type,
                        accrediting_provider)
            VALUES ('B1T',
                    'bat 1',
                    (SELECT id FROM "recruitment_cycle"
                               ORDER BY year DESC limit 1),
                    'N',
                    'O',
                    'Y')
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
