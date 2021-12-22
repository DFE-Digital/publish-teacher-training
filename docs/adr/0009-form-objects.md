# 9. Form objects

Date: 2021-12-21

## Status

Accepted

## Context

We need an approach to model business validations. We would like to avoid putting these directly into the database models to give us flexibility in handling evolving UI related business requirements - particularly now that the publish repo will be integrated into the main repo. The publish interface may have different business rules than other areas of the application.

## Options

### 1. Keep validations in the database models

This option would involve adding the validations directly into the database models.

#### Pros

- Validations would be in one place

#### Cons

- Less flexible in the future
- More work to change existing code if some validations aren't necessary to enforce in other contexts

### 2. Form objects

This option would involve using the form object pattern to handle the validation rules.

#### Pros

- Validations are contained in the areas of the application that need them
- Keeps database models flexible and easy to change
- Maintains a clear boundary between the database models and the controllers

#### Cons

- Validations are not in one place

## Decision

Given the form object is a pattern used in many GOV.UK services and the benefits it provide, we have decided to go with this option.

## Consequences

This option will allow us to easily model and enforce business rules based on the domains of the application. In order to enforce consistency, we'll leverage a pattern used by the Register service to write our form objects. The rationale behind this is based on the fact that Register has already solved tricky UX issues with this pattern and have battle tested it in production with more than 10,000 trainees entered in the system.
