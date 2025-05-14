# Developer Onboarding

## Brief Product Context

Our codebase currently hosts the following services:

- [Publish teacher training courses](https://www.publish-teacher-training-courses.service.gov.uk) [(QA environment)](https://qa.publish-teacher-training-courses.service.gov.uk)
- [Find teacher training courses](https://find-teacher-training-courses.service.gov.uk) [(QA environment)](https://qa.find-teacher-training-courses.service.gov.uk)
- [Teacher training courses API](https://api.publish-teacher-training-courses.service.gov.uk) [(QA environment)](https://qa.api.publish-teacher-training-courses.service.gov.uk)

In order to manage the data of these services, we also provide a [Support Console](https://www.publish-teacher-training-courses.service.gov.uk/support) [(QA environment)](https://qa.publish-teacher-training-courses.service.gov.uk/support).

The "Publish teacher training courses" service provides a user interface for Initial Teacher Training providers (ITT Providers) to author and publish Initial Teacher Training courses.

The "Find teacher training courses" service provides a user interface for Initial Teacher Training candidates to search and find initial teacher training courses. A candidate can then click through to our adjacent service, [Apply for teacher training](https://www.apply-for-teacher-training.service.gov.uk), to apply to initial teacher training courses.

You can refer to the [Teacher services map](https://becoming-a-teacher.design-history.education.gov.uk/service-map) to understand more about where the services sit.

## Process

We follow a [Kanban](https://www.atlassian.com/agile/kanban) development process.

We currently have the following team meetings:

- Daily Standup - We have a daily 15-minute [standup](https://www.atlassian.com/agile/scrum/standups) meeting for each team member to share progress, potential blockers, and current work-in-progress with the other team members. All multi-disciplinary team members attend this meeting.
- Weekly Dev Check-Ins - We have a meeting every Wednesday to discuss developer-oriented tasks and pain points. Only developers attend this meeting.
- Bi-Weekly Retrospective - We have a [retrospective](https://www.atlassian.com/agile/scrum/retrospectives) meeting every 2 weeks. We typically highlight "what went well?", "what could be better?", "what should we change?" All multi-disciplinary team members attend this meeting.
- Weekly Support Handover - We have a 15-minute support handover meeting every Monday. Only the developer on the support rotation from last week, the developer on support for this week, and the backup support developer attend this meeting.

Developers also have weekly 1:1 meetings with the Tech Lead.

### Support Rotation

Each developer spends a week as the support developer. We cycle through all members of the development team being on support and then loop back to the developer on support the longest time ago in a Last-in First-out (LIFO) fashion.

- We use [this Excel sheet](https://educationgovuk.sharepoint.com.mcas.ms/:x:/r/sites/TeacherServices/_layouts/15/doc2.aspx?sourcedoc=%7B0F13F6E0-6B06-40E3-9FD1-6E1FE169029F%7D&file=Find%20&%20Apply%20support%20rota.xlsx=&action=default&mobileredirect=true) to track our support rotation.
- We use [this Trello board](https://trello.com/b/StWME7Ig/ops-support-find-apply-ticket-tracker) to monitor and track incoming support tickets that require developer or Policy support.

In order to gain access to the Production and Sandbox environments, you will need to create a [PIM Request](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management) via the Azure console.

## Tech Stack

- [Ruby](https://ruby-lang.org) - We use Ruby to build the majority of our application.
- [Ruby on Rails](https://rubyonrails.org) - We use Ruby on Rails as our web framework.
- [JavaScript](https://developer.mozilla.org/docs/Web/JavaScript) - We sparingly use JavaScript for [progressive enhancement](https://www.gov.uk/service-manual/technology/using-progressive-enhancement).
- [Stimulus](https://stimulus.hotwired.dev) - We use Stimulus as our framework for the majority of our JavaScript usage.
- [RSpec](https://rspec.info) - We use RSpec as our testing framework.

## Key Libaries

- [GOV.UK Frontend](https://github.com/alphagov/govuk-frontend) - The GOV.UK Frontend provides the assets required to follow the [GOV.UK Design System](https://design-system.service.gov.uk).
- [X-GOVUK Components](https://github.com/x-govuk/govuk-components) - This gem provides out-of-the-box [View Components](https://viewcomponent.org) for the GOV.UK Design System components.
- [X-GOVUK Form Builder](https://github.com/x-govuk/govuk-form-builder) - This gem provides a custom [Rails Form Builder](https://api.rubyonrails.org/v8.0/classes/ActionView/Helpers/FormBuilder.html) that follows the GOV.UK Design System styles.
- [DfE Analytics](https://github.com/DFE-Digital/dfe-analytics) - The DfE Analytics gem is used to pipe web analytics to DfE's [BigQuery](https://cloud.google.com/bigquery) instances. The Data & Insights team then uses [Looker Studio](https://lookerstudio.google.com) to create insight dashboards.

## External APIs

- [GOV.UK Notify](https://www.notifications.service.gov.uk) - We use GOV.UK Notify as our email provider.
- [DfE Sign In](https://services.signin.education.gov.uk) - We use DfE Sign In (DSI) to authenticate Providers and Support Users.

## Tools

- [GitHub](https://github.com) - All of our source code is stored in a git repository on GitHub.
  - [GitHub Actions](https://github.com/features/actions) - We use GitHub Actions for our CI/CD pipelines.
- [Trello](https://trello.com) - We use Trello to keep track of our tasks and development progress.
- [Docker](https://www.docker.com) - We use Docker to containerise our services.
- [Azure](https://azure.microsoft.com) - We use Azure to host our services.
  - [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/products/kubernetes-service) - We use Kubernetes via AKS to manage our containerised applications.
  - [Azure Database of PostgreSQL](https://azure.microsoft.com/products/postgresql) - We use a PostgreSQL database for our main database with upcoming plans to adopt
  - [Azure Cache for Redis](https://azure.microsoft.com/products/cache) - We use Redis for our application cache and background job queue.
  - [Azure Key Vault](https://azure.microsoft.com/products/key-vault) - All of our secrets and credentials are stored in Azure Key Vault per deployed environment.
- [Sentry](https://sentry.io) - We use Sentry to monitor production errors.
- [Skylight](https://skylight.io) - We use Skylight as our application performance monitoring (APM) tool. Skylight helps us identify slow endpoints.
- [Logit](https://logit.io) - We use Logit to view our application logs. It provides a comparable user experience to [Kibana](https://www.elastic.co/kibana).
- [Grafana](https://grafana.com) - We use Grafana as our infrastructure metrics dashboards. It displays graphs of CPU usage, memory usage, and container restarts per each pod.

## Important Links

- The Publish and Find teacher training courses team's ["About us"](https://ukgovernmentdfe.slack.com/docs/T50RK42V7/F07Q7R5A278) canvas on Slack. This details the team members, the vision and mission of the team, the team's priorities, general important links for the team, shared credentials, and other general information.
- The [#ts_publish_and_find_tech](https://ukgovernmentdfe.slack.com/archives/C07RERNAS2H) Slack channel.
- The [Becoming a Teacher Design History](https://becoming-a-teacher.design-history.education.gov.uk) website provides a background of how the service line services have come to be. The following sections are incredibly useful for catching up on the history of the Publish and Find teacher training services:
  - [Design history - Publish teacher training courses](https://becoming-a-teacher.design-history.education.gov.uk/publish-teacher-training-courses)
  - [Design history - Find teacher training courses](https://becoming-a-teacher.design-history.education.gov.uk/find-teacher-training)
  - [Design history - Publish teacher training courses support console](https://becoming-a-teacher.design-history.education.gov.uk/support-for-publish)
- We write up [our Architecture Decision Records (ADRs)](adr/index.md) and publish them to the repository.

## Conventions

To promote development velocity, we have aligned on multiple [code conventions](conventions.md).

## Unconventional parts of our codebase

- The service was originally built in C# with singular table names. To prevent breaking our analytics, we have continued to singularise table names. We configure this in `config/application.rb`.

  ```ruby
  config.active_record.pluralize_table_names = false
  ```

## GOV.UK and DFE tech docs

- [The GDS Way](https://gds-way.digital.cabinet-office.gov.uk) - General GOV.UK guidelines for building digital services.
- [The Service Standard](https://www.gov.uk/service-manual/service-standard) - When the service undergoes a [Service Assessment](https://www.gov.uk/service-manual/service-assessments), the service will be graded against each point of the Service Standard.
- [DfE Technical Guidance](https://technical-guidance.education.gov.uk) - The documentation here provides a DfE-tailored variant of general digital services guidelines.
- [Teacher Services technical documentation](https://tech-docs.teacherservices.cloud) - This site sources documentation about all DfE repositories and renders the markdown files in the GOV.UK tech docs [Middleman](https://middlemanapp.com) static site template.
