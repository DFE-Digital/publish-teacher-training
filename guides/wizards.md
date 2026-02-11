# Multi-Step Forms (dfe-wizard)

This guide covers multi-step forms in the application: those already using the [dfe-wizard](https://github.com/DFE-Digital/dfe-wizard) gem and those that could be migrated to it.

## What is dfe-wizard?

dfe-wizard is a framework for building multi-step forms in Rails with conditional branching, state management, and automatic documentation generation. It provides:

- **Steps Processor** - defines the flow as a graph with conditional edges
- **Steps** - form objects with ActiveModel validations and attributes
- **State Store** - bridges the wizard and the persistence layer, exposes predicates for branching
- **Repository** - handles reading/writing data to the database (or session, cache, etc.)
- **Route Strategy** - generates step URLs from Rails routes

See the [gem README](https://github.com/DFE-Digital/dfe-wizard) for full API documentation.

## Directory structure

A wizard implementation follows this layout:

```
app/
  wizards/
    {name}_wizard.rb                          # Main wizard class (includes DfE::Wizard)
    {name}_wizard/
      steps/
        step_one.rb                           # Step classes (include DfE::Wizard::Step)
        step_two.rb
      state_stores/
        {name}.rb                             # State store (include DfE::Wizard::StateStore)
      repositories/
        {name}.rb                             # Repository (inherit DfE::Wizard::Repository::Model)
  controllers/{service}/
    {resource}/{wizard_name}/
      {wizard_name}_controller.rb             # Base controller (shared new/create actions)
      step_one_controller.rb                  # Per-step controllers (inherit base)
      step_two_controller.rb
  views/{service}/
    {resource}/{wizard_name}/
      step_one/new.html.erb                   # Per-step views
      step_two/new.html.erb

config/routes/{service}.rb                    # Routes for each step

spec/
  wizards/{name}_wizard/                      # Unit tests for steps, state stores, repositories

guides/wizards/
  {name}_wizard.md                            # Auto-generated documentation
  {name}_wizard.mmd                           # Mermaid diagram
  {name}_wizard.dot                           # Graphviz diagram
```

## Implemented wizards

### A level requirements

The only multi-step form currently using dfe-wizard.

- **Wizard:** `app/wizards/a_levels_wizard.rb`
- **Steps:** `app/wizards/a_levels_wizard/steps/`
  - `what_a_level_is_required` - select subject and minimum grade
  - `add_a_level_to_a_list` - review list, add another or continue
  - `remove_a_level_subject_confirmation` - confirm subject removal
  - `consider_pending_a_level` - accept pending A levels?
  - `a_level_equivalencies` - accept equivalency tests?
- **State store:** `app/wizards/a_levels_wizard/state_stores/a_level.rb`
- **Repositories:** `app/wizards/a_levels_wizard/repositories/`
- **Controllers:** `app/controllers/publish/courses/a_level_requirements/`
- **Views:** `app/views/publish/courses/a_level_requirements/`
- **Routes:** `config/routes/publish.rb` (under `/a-levels-or-equivalency-tests/`)
- **Auto-generated docs:** `guides/wizards/a_levels_wizard.md`

## Multi-step forms not yet using dfe-wizard

The following forms use traditional multi-step patterns (manual controller chaining, `CourseBasicDetailConcern`, or stashing to session). They are candidates for migration to dfe-wizard.

### Course creation

The largest multi-step flow in the app. Uses `CourseBasicDetailConcern` and `CourseCreationStepService` to chain 15+ steps.

- **Controllers:** `app/controllers/publish/courses/` (19 step controllers including `OutcomeController`, `LevelController`, `SubjectsController`, `SchoolsController`, `StudyModeController`, `StartDateController`, `AgeRangeController`, `FundingTypeController`, `RatifyingProviderController`, visa sponsorship steps, etc.)
- **Step service:** `app/services/publish/course_creation_step_service.rb`
- **Creation service:** `app/services/courses/creation_service.rb`
- **Concern:** `app/models/concerns/publish/course_basic_detail_concern.rb`
- **Routes:** `config/routes/publish.rb` (under courses resources)

### Degrees

3-step flow for setting degree requirements on a course.

- **Controllers:** `app/controllers/publish/courses/degrees/`
  - `start_controller.rb` - is a degree required?
  - `grade_controller.rb` - minimum classification
  - `subject_requirements_controller.rb` - subject requirements
- **Forms:** `app/forms/publish/degree_start_form.rb`, `degree_grade_form.rb`, `subject_requirement_form.rb`
- **Views:** `app/views/publish/courses/degrees/`

### GCSEs

Single-page form (edit/update) for GCSE requirements. Not multi-step, but could be split into steps if requirements grow.

- **Controller:** `app/controllers/publish/courses/gcse_requirements_controller.rb`
- **Form:** `app/forms/publish/gcse_requirements_form.rb`

### Provider onboarding (Support)

3-step flow for support users to onboard a new provider.

- **Controllers:**
  - `app/controllers/support/providers/onboardings_controller.rb` - provider details
  - `app/controllers/support/providers/onboarding/contacts_controller.rb` - contact details
  - `app/controllers/support/providers/onboarding/checks_controller.rb` - check and confirm
- **Forms:** `app/forms/support/provider_form.rb`, `app/forms/support/provider_contact_form.rb`
- **Pattern:** Uses session stashing between steps

### Provider onboarding (Public)

Public-facing form (accessed via unique link) for providers to submit onboarding details.

- **Controller:** `app/controllers/publish/provider_onboarding_controller.rb`
- **Model:** `ProvidersOnboardingFormRequest`
- **Flow:** form -> check answers -> confirm -> submitted

### Add school

Search and add a single school to a provider. Uses search + check/confirm pattern.

- **Controller:** `app/controllers/publish/providers/schools_controller.rb`
- **Form:** `app/forms/publish/school_form.rb`

### Add multiple schools

Bulk add schools by URN.

- **Controllers:**
  - `app/controllers/publish/providers/schools/multiple_controller.rb` - input URNs
  - `app/controllers/publish/providers/schools/check_multiple_controller.rb` - review and confirm
- **Form:** `app/forms/urn_form.rb`

### Add recruitment cycle

Single-page form for support users. Not multi-step.

- **Controller:** `app/controllers/support/recruitment_cycles_controller.rb`
- **Form:** `app/forms/support/recruitment_cycle_form.rb`

### Add provider

Single-page form. Part of support interface.

- **Controller:** `app/controllers/support/providers_controller.rb`
