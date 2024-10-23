# 12. Formalize Accredited Provider relationships

Date: 23/10/24

## Status

Proposal

## Context

We have a database table `provider` that has an implicit self-join relationship based on another column `accrediting_provider`.

The relationship that currently exists is unconventional with respect to a normalised relational database.

Making the relationship more conventional will allow us to query, validate and enforce the realtionships easily and will reduce the uncertainty about the nature of this relationship.


### Misuse of the existing relationships

We have seen Accredited provider relationships that exist solely for organisational reasons. This happens when Accredited provider A1 is an accredited provider for provider A2 but there is no expectation or intention for A1 to be the accredited provdier for courses run by A2. This feels like an abuse of the accredited provider association.

### Definitions

 - A Training Provider
     * A provider that runs training courses directly.
     * |or|
     * A provider that has an subordinate assocation to another provider (accredited).
 - An Accredited Provider
     * A provider that has an authoratative assocation to another provider (training).
 - Accrediting Provider
     * A provider that accredits one or more courses on behalf of one or more training provider.
 - An Accredited Provider Relationship
     * A directional association between an accredited provider and another provider.

An Accredited provider can run training courses, meaning they are a training provider and an accredited provider.

An Accredited provider can be accredited by another accredite provider.

#### Three levels of providers scenario

Accredited provider A1

Accredited provider A2

Training provider T1

```mermaid
flowchart LR;
T1
A2
A1

T1 --> A2 --> A1;
```

 - A2 has an accredited provider relationship with A1. A1 is the accredited provider in this relationship.
 - A2 is the accredited provider for T1. T1 courses are accredited by A2.
 - A2 runs training courses and self accredits those courses.


### Assumptions

1. A provider is an Accredited provider if the value in the `accrediting_provider` column is `'Y'`
2. A provider is not an Accredited provider if the value in the `accrediting_provider` column is `'N'`
3. A Course must either be run by an Accredited provider |or| reference an Accredited provider (via `courses.accredited_provider_code`)
4. There must exist an accredited provider relationship between the training provider and the accredited provider for the Course accredited provider to be valid.


### Training Provider -> Accredited Provider association

```mermaid
flowchart LR;
TrainingProvider --> Enrichments --> AccreditedProvider;
```

### Course -> Accredited Provider association
```mermaid
flowchart LR;
TrainingProvider --> Course --> AccreditedProvider;
```

## Options

### 1. Leave the relationships as they are

A training provider stores their accredited provider relationships in a serialized json column called `accredited_provider_enrichments`. The primary key is stored as a property in this serialized string. This columns is of type `jsonb` but the json type of the value is `string`, not `object` using a key that is outdated and misleading `'UcasProviderCode'`.

```
manage_courses_backend_development=# select jsonb_typeof(accrediting_provider_enrichments) from provider limit 1;
 jsonb_typeof
--------------
 string
(1 row)
```

This requires us to pattern match the string to find a training providers accredited provider associations. We cannot coerce the value to a jsonb object (array) because of the quote escaping in the stored string.

#### Pros

- No effort expended and other work can be prioritised

#### Cons

- Consuses new developers
- Leaves the data in an under contrained state
- Inefficient methods for querying entity relationships

### 2. Create typical self-join has_many through pivot table relationship


To be filled out
```ruby
 # app/models/provider.rb

  has_many :accredited_accreditations,
           class_name: 'ProviderAccreditation',
           foreign_key: :training_provider_id

  has_many :training_accreditations,
           class_name: 'ProviderAccreditation',
           foreign_key: :accredited_provider_id

  has_many :accredited_providers,
           through: :accredited_accreditations,
           source: :accredited_provider,
           class_name: 'Provider'

  has_many :training_providers,
           through: :training_accreditations,
           source: :training_provider,
           class_name: 'Provider'
```

#### Pros

- Query the training provider / accredited provider relationships through typical relational associations
- Index the columns used to make these queries.
- More formally distinguish accredited and accrediting providers.
- Database validations (if desired) on which accredited providers can accredit which courses.
- Opportunity to clarify definintions and understand how we are using them.

#### Cons

- None!

## Decision

The change option that we're proposing or have agreed to implement.

## Consequences

What becomes easier or more difficult to do and any risks introduced by the change that will need to be mitigated.
