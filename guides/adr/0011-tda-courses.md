# 11. Add TDA Courses to Find/Publish

Date: 29/02/2024

## Status

Proposed

## Glossary

TDA - Teacher degree apprenticeship

## Context

Trainee teachers will soon be able to gain a degree through an apprenticeship,
instead of through the traditional university route into the profession.

A degree apprenticeship allows trainees to study towards an undergraduate or
master’s degree while they work, getting invaluable industry experience and
earning a salary. Trainees off-the-job training takes place in working hours,
and trainees won’t have to pay for their tuition.

Degree apprenticeships are jobs with training. On completion of the apprenticeship,
trainees will achieve an undergraduate or master’s degree – just like someone
who has got their degree through a traditional route.

Our platform currently supports courses through API v1 in the Publish module.
However, it lacks support for the additional value: 'tda' representing the degree apprenticeship program.
Additionally, the course wizard in Publish needs improvement to accept TDA
courses seamlessly. Furthermore, the details course tab requires enhancements to
automatically set degrees as not required for TDA courses.
Lastly, there's a need for a filtering mechanism in the Find module to streamline course discovery.

## Decision

API v1 Enhancement - We will extend API v1 in the Publish module to accommodate the additional values. This will involve updating the API attributes and documentation accordingly. The new values are:
    * Qualifications field: 'undergraduate_degree', representing the course awards a degree.
    * Program type field: 'teacher_degree_apprenticeship' representing the new route into teaching.

Course Wizard Enhancement: The add course wizard in Publish will be improved to seamlessly accept TDA courses. This enhancement aims to streamline the course addition process for users and ensure compatibility with the new course types.

Description Course Tab Enhancement: The description course tab functionality will be enhanced to automatically configure degrees as not required when adding TDA courses. This automation will simplify course management for users and ensure accurate representation of TDA course requirements.

Filtering Mechanism Addition: A filtering mechanism will be added to the Find app to facilitate efficient course discovery. Users will be able to filter courses based on TDA parameters, enhancing the overall user experience and enabling quicker access to TDA courses.

## Consequences

Efficiency Gains: The filtering mechanism in the Find module will improve efficiency by enabling users to quickly find TDA courses.

Publish API consumers V1 changes: The V1 changes can potentially break their integrations, so we will ensure that all teams, including Apply, Register, Vendors, Providers that uses Vendor API, and others, integrate TDA courses in their respective integrations to maintain consistency across the platform.
