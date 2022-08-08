SELECT
    c.id,
    c.id AS course_id,
    c.name AS course_name,
    c.course_code,
    c.program_type,
    c.qualification,
    c.study_mode,
    c.is_send,
    c.degree_grade,
    c.changed_at,
    c.accredited_body_code,
    p.id AS provider_id,
    p.provider_name,
    ab.provider_name AS accredited_body_provider_name,
    p.recruitment_cycle_id,
    rc.year AS recruitment_cycle_year,
    subjects.subject_codes,
    cc.is_salary,
    cc.is_full_time,
    cc.is_part_time,
    cc.funding_type
FROM course AS c
INNER JOIN provider AS p
    ON p.id = c.provider_id
INNER JOIN recruitment_cycle AS rc
    ON rc.id = p.recruitment_cycle_id
FULL OUTER JOIN provider AS ab
    ON (ab.provider_code = c.accredited_body_code AND ab.recruitment_cycle_id = p.recruitment_cycle_id)
FULL OUTER JOIN (
    SELECT
    course_id,
    array_remove(array_agg(s.subject_code), NULL) AS subject_codes
    FROM course_subject AS cs
    INNER JOIN subject AS s
        ON s.id = cs.subject_id
    GROUP BY cs.course_id) AS subjects ON subjects.course_id = c.id
INNER JOIN (
    SELECT
        _c.id,
        (
            CASE
            WHEN program_type in ('SS', 'TA') THEN true
            ELSE false
            END
        ) AS is_salary,
        (
            CASE
            WHEN study_mode in ('F', 'B') THEN true
            ELSE false
            END
        ) as is_full_time,
        (
            CASE
            WHEN study_mode in ('P', 'B') THEN true
            ELSE false
            END
        ) as is_part_time,
        (
            CASE
            WHEN program_type = 'SS' THEN 'salary'
            WHEN program_type = 'TA' THEN 'apprenticeship'
            WHEN program_type in ('HE', 'SC', 'SD')  THEN 'fee'
            ELSE 'unknown'
            END
        ) AS funding_type,
        (
            CASE
            WHEN _p.can_sponsor_student_visa = true AND program_type in ('HE', 'SC', 'SD') THEN true
            WHEN _p.can_sponsor_skilled_worker_visa = true AND program_type in ('SS', 'TA') THEN true
            ELSE false
            END
        ) AS provider_can_sponsor_visa
    FROM course AS _c
    INNER JOIN provider AS _p
        ON _p.id = _c.provider_id
)  AS cc
    ON cc.id = c.id
