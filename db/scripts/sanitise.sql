DELETE FROM session;
DELETE FROM access_request;
DELETE FROM audit;

UPDATE "user"
       SET email=concat('anonimized-user-',id,'@example.org'),
           first_name='anon',
           last_name='anon',
           sign_in_user_id=null
       WHERE email NOT LIKE '%@digital.education.gov.uk'
             AND email NOT LIKE '%@education.gov.uk';
