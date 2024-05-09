# 7. JavaScript Linting and code style

Date: 2020-08-25

## Status

Accepted

## Context

We need tooling to ensure that our Javascript is in consistent code style and for us to be notified when
it is not.  

## Options

### 1. [ESLint](https://eslint.org/)/[Prettier](https://prettier.io/)

Two different tools, ESLint performs automated scans of your JavaScript files for common syntax 
and style errors. Prettier scans your files for style issues and automatically reformats your code 
to ensure consistent rules are being followed for indentation, spacing, semicolons, single quotes vs double quotes, etc.

#### Pros

- Extremely configurable
- Create custom style standards
- Automatically format code

#### Cons

- requires more dependencies which require configuring
- Can lead to bikeshedding when discussing rules/patterns which sometimes just end up being personal preferences

### 2. [StandardJS](https://standardjs.com/)

Opinionated JavaScript linter. 

#### Pros

- No configuration
- [GDS use it when building their services and have a great write up about it in GDS Way](https://gds-way.cloudapps.digital/manuals/programming-languages/js.html#linting)
- Automatically format code using `--fix` flag

#### Cons

- Some developers may have strong personal opinions/preferences

### 3. Combination of option 1 & 2

Install ESLint & Prettier but apply a third-party plugin to apply standardJS rules as a baseline. 

#### Pros

- allows the best of both worlds 
- can add custom rules to overcome rules with standardjs

#### Cons

- Possibility of leading to bikeshedding 
- Relying on third-party plugin to be insync with standardjs rules
- requires additional configuration in addition to what is needed for option 1.

## Decision

We decided as a team that option 2 would be the easiest and quickest option to implement. It also follows the ways that GDS work.
If we found it too restrictive at a later date we could then switch to option 3 and customise the rules if need be. 
