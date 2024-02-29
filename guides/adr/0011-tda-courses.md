Title: Add PGTA/TDA Courses to Find/Publish

Date: 29/02/2024

Status: Proposed

Context:

Trainee teachers will soon be able to gain a degree through an apprenticeship,
instead of through the traditional university route into the profession.

A degree apprenticeship allows candidates to study towards an undergraduate or
master’s degree while they work, getting invaluable industry experience and
earning a salary. Candidate's off-the-job training takes place in your working hours,
and candidates won’t have to pay for their tuition.

Degree apprenticeships are jobs with training. On completion of the apprenticeship,
candidates will achieve an undergraduate or master’s degree – just like someone
who has got their degree through a traditional route.

Our platform currently supports courses through API v1 in the Publish module.
However, it lacks support for two additional values: pgta and pgta_with_qts,
representing the degree apprenticeship program.
Additionally, the course wizard in Publish needs improvement to accept PGTA/TDA
courses seamlessly. Furthermore, the details course tab requires enhancements to
automatically set degrees as not required for TDA courses.
Lastly, there's a need for a filtering mechanism in the Find module to streamline course discovery.

Decision:

API v1 Enhancement: We will extend API v1 in the Publish module to accommodate the two additional values: pgta and pgta_with_qts, representing the degree apprenticeship program. This will involve updating the API attributes and documentation accordingly.

Course Wizard Enhancement: The add course wizard in Publish will be improved to seamlessly accept PGTA/TDA courses. This enhancement aims to streamline the course addition process for users and ensure compatibility with the new course types.

Details Course Tab Enhancement: The details course tab functionality will be enhanced to automatically configure degrees as not required when adding TDA courses. This automation will simplify course management for users and ensure accurate representation of TDA course requirements.

Filtering Mechanism Addition: A filtering mechanism will be added to the Find app to facilitate efficient course discovery. Users will be able to filter courses based on TDA parameters, enhancing the overall user experience and enabling quicker access to TDA courses.

Consequences:

Efficiency Gains: The filtering mechanism in the Find module will improve efficiency by enabling users to quickly find TDA courses.
Publish API consumers V1 changes: Ensuring that all teams, including Apply, Register, Vendors, Providers that uses Vendor API, and others, integrate TDA courses in their respective integrations to maintain consistency across the platform.
