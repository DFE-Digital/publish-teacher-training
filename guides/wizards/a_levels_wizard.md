# Wizard Documentation

**Structure Type:** `graph`
**Generated:** 2026-02-02T10:55:47Z
**Processor:** DfE::Wizard::StepsProcessor


## Overview

| Metric                           | Value                       |
|----------------------------------|-----------------------------|
| Total Steps                      | 5              |
| Simple Transitions               | 0       |
| Conditional Transitions          | 0         |
| Multiple Conditional Transitions | 0        |
| Custom Branching Transitions     | 0       |
| **Total Transitions**            | **0**    |


## Root Entry Points (Dynamic)

This wizard uses conditional root logic. Users may enter at different steps based on runtime state evaluation.

### Possible Entry Points

- `add_a_level_to_a_list`
- `what_a_level_is_required`

**Determination:** Evaluated at initialization based on wizard state. See "Conditional Root Logic" section for details on which conditions route to which entry points.


## Wizard Flow

```
[:add_a_level_to_a_list]
├─→ [:what_a_level_is_required]  (✓)
│   ↓
│ [:add_a_level_to_a_list]
└─→ [:consider_pending_a_level]  (✗)
    ↓
  [:a_level_equivalencies]
    ↓
  [:course_edit]
[:what_a_level_is_required]
  ↓
[:add_a_level_to_a_list]
├─→ [:what_a_level_is_required]  (✓)
└─→ [:consider_pending_a_level]  (✗)
    ↓
  [:a_level_equivalencies]
    ↓
  [:course_edit]
```

### Legend

- **━━** Simple edge (linear progression, no condition)
- **─┬─** Conditional edge (if/else decision point)
- **┼** Multiple conditional edge (N-way branching)
- **⊕** Custom branching edge (complex status-driven routing)


## Steps Inventory

| Step ID | Label | Class |
|---------|-------|-------|
| `what_a_level_is_required` | What A Level Is Required | `ALevelSteps::WhatALevelIsRequired` |
| `add_a_level_to_a_list` | Add A Level To A List | `ALevelSteps::AddALevelToAList` |
| `remove_a_level_subject_confirmation` | Remove A Level Subject Confirmation | `ALevelSteps::RemoveALevelSubjectConfirmation` |
| `consider_pending_a_level` | Consider Pending A Level | `ALevelSteps::ConsiderPendingALevel` |
| `a_level_equivalencies` | A Level Equivalencies | `ALevelSteps::ALevelEquivalencies` |


## Detailed Step Specifications

### Step: `what_a_level_is_required`

**Label:** What A Level Is Required
**Class:** `ALevelSteps::WhatALevelIsRequired`
**Entry Point:** ✓ Yes
**Exit Points:** `add_a_level_to_a_list`

#### Description

Placeholder for step description. Add contextual information about
this step's purpose, user interactions, and business logic.

#### Attributes

| Attribute | Type | Required | Description |
|-----------|------|:--------:|-------------|
| `subject` | `ActiveModel::Type::String` | ✗ |  |
| `other_subject` | `ActiveModel::Type::String` | ✗ |  |
| `minimum_grade_required` | `ActiveModel::Type::String` | ✗ |  |
| `uuid` | `ActiveModel::Type::String` | ✗ |  |

#### Validations

- **subject** (`presence`): 
- **other_subject** (`presence`): 
- **minimum_grade_required** (`chars_count`): 

#### Operations

| Operation | Description |
|-----------|-------------|
| `validate` | Validate operation |
| `persist` | Persist operation |


### Step: `add_a_level_to_a_list`

**Label:** Add A Level To A List
**Class:** `ALevelSteps::AddALevelToAList`
**Entry Point:** ✓ Yes
**Exit Points:** `consider_pending_a_level`, `what_a_level_is_required`

#### Description

Placeholder for step description. Add contextual information about
this step's purpose, user interactions, and business logic.

#### Attributes

| Attribute | Type | Required | Description |
|-----------|------|:--------:|-------------|
| `add_another_a_level` | `ActiveModel::Type::String` | ✗ |  |

#### Validations

- **add_another_a_level** (`presence`): 
- **add_another_a_level** (`inclusion`): 

#### Operations

| Operation | Description |
|-----------|-------------|
| `validate` | Validate operation |
| `persist` | Persist operation |


### Step: `remove_a_level_subject_confirmation`

**Label:** Remove A Level Subject Confirmation
**Class:** `ALevelSteps::RemoveALevelSubjectConfirmation`
**Entry Point:** ✗ No
**Exit Points:** `add_a_level_to_a_list`

#### Description

Placeholder for step description. Add contextual information about
this step's purpose, user interactions, and business logic.

#### Attributes

| Attribute | Type | Required | Description |
|-----------|------|:--------:|-------------|
| `uuid` | `ActiveModel::Type::String` | ✗ |  |
| `confirmation` | `ActiveModel::Type::String` | ✗ |  |

#### Validations

- **uuid** (`presence`): 

#### Operations

| Operation | Description |
|-----------|-------------|
| `validate` | Validate operation |
| `persist` | Persist operation |


### Step: `consider_pending_a_level`

**Label:** Consider Pending A Level
**Class:** `ALevelSteps::ConsiderPendingALevel`
**Entry Point:** ✗ No
**Exit Points:** `a_level_equivalencies`

#### Description

Placeholder for step description. Add contextual information about
this step's purpose, user interactions, and business logic.

#### Attributes

| Attribute | Type | Required | Description |
|-----------|------|:--------:|-------------|
| `pending_a_level` | `ActiveModel::Type::Value` | ✗ |  |

#### Validations

- **pending_a_level** (`presence`): 
- **pending_a_level** (`inclusion`): 

#### Operations

| Operation | Description |
|-----------|-------------|
| `validate` | Validate operation |
| `persist` | Persist operation |


### Step: `a_level_equivalencies`

**Label:** A Level Equivalencies
**Class:** `ALevelSteps::ALevelEquivalencies`
**Entry Point:** ✗ No
**Exit Points:** `course_edit`

#### Description

Placeholder for step description. Add contextual information about
this step's purpose, user interactions, and business logic.

#### Attributes

| Attribute | Type | Required | Description |
|-----------|------|:--------:|-------------|
| `accept_a_level_equivalency` | `ActiveModel::Type::Value` | ✗ |  |
| `additional_a_level_equivalencies` | `ActiveModel::Type::Value` | ✗ |  |

#### Validations

- **accept_a_level_equivalency** (`presence`): 
- **accept_a_level_equivalency** (`inclusion`): 
- **additional_a_level_equivalencies** (`words_count`): #<Proc:0x00007a6a452f60a0 /home/inulty-dfe/Code/publish-teacher-training/app/wizards/a_level_steps/a_level_equivalencies.rb:15 (lambda)>

#### Operations

| Operation | Description |
|-----------|-------------|
| `validate` | Validate operation |
| `persist` | Persist operation |


## Transitions Reference

This wizard contains **5 transitions** across 4 types:

- **4 simple transitions** – Linear progression (unconditional)
- **1 conditional transitions** – If/else branching logic
- **0 multiple conditional transitions** – N-way branching
- **0 custom branching transitions** – Complex status-driven routing


### Simple Transitions

Simple transitions allow linear, unconditional progression from one step to the next.

| From | To | Behavior |
|------|-----|----------|
| `what_a_level_is_required` | `add_a_level_to_a_list` | Always proceeds (no condition) |
| `remove_a_level_subject_confirmation` | `add_a_level_to_a_list` | Always proceeds (no condition) |
| `consider_pending_a_level` | `a_level_equivalencies` | Always proceeds (no condition) |
| `a_level_equivalencies` | `course_edit` | Always proceeds (no condition) |


### Conditional Transitions (If/Else)


Conditional transitions split the flow into two branches based on a predicate evaluation.


#### `add_a_level_to_a_list` → `what_a_level_is_required` OR `consider_pending_a_level`

| Property | Value |
|----------|-------|
| From | `add_a_level_to_a_list` |
| Condition | `Condition` |
| Then (if true) | `what_a_level_is_required` |
| Else (if false) | `consider_pending_a_level` |

**Flow Logic:**

Evaluates the predicate `Condition`:
- If condition is **true** → proceed to `what_a_level_is_required`
- If condition is **false** → proceed to `consider_pending_a_level`
"


## Wizard Statistics

| Metric | Count |
|--------|-------|
| Total Steps | 5 |
| Simple Transitions | 0 |
| Conditional Transitions | 0 |
| Multiple Conditional Transitions | 0 |
| Custom Branching Transitions | 0 |
| **Total Transitions** | **5** |


## Example User Journeys

### Journey 1: Typical Path

```
1. [Entry]  Entry Step
2. [Linear] Step A
3. [Cond]   Step B or C (conditional)
4. [N-way]  Step D (branching)
5. [Exit]   Terminal Step
```

### Journey 2: Alternative Path

```
1. [Entry]  Entry Step (alternate)
2. [Linear] Step A
3. [Status] Different terminal step based on status
```

**Note:** Actual journeys depend on wizard state transitions and predicates.


## Raw Metadata

```json
{
  :structure_type: "graph",
  :root_step: [
    "add_a_level_to_a_list",
    "what_a_level_is_required"
  ],
  :steps: {
    :what_a_level_is_required: {
      :class: "ALevelSteps::WhatALevelIsRequired",
      :label: "What A Level Is Required",
      :attributes: [
        {
          :name: "subject",
          :type: "ActiveModel::Type::String"
        },
        {
          :name: "other_subject",
          :type: "ActiveModel::Type::String"
        },
        {
          :name: "minimum_grade_required",
          :type: "ActiveModel::Type::String"
        },
        {
          :name: "uuid",
          :type: "ActiveModel::Type::String"
        }
      ],
      :validators: [
        {
          :name: "subject",
          :class: "ActiveModel::Validations::PresenceValidator",
          :type: "presence",
          :message: null
        },
        {
          :name: "other_subject",
          :class: "ActiveModel::Validations::PresenceValidator",
          :type: "presence",
          :message: null
        },
        {
          :name: "minimum_grade_required",
          :class: "CharsCountValidator",
          :type: "chars_count",
          :message: null
        }
      ],
      :operations: [
        {
          :name: "validate",
          :description: "Validate operation"
        },
        {
          :name: "persist",
          :description: "Persist operation"
        }
      ]
    },
    :add_a_level_to_a_list: {
      :class: "ALevelSteps::AddALevelToAList",
      :label: "Add A Level To A List",
      :attributes: [
        {
          :name: "add_another_a_level",
          :type: "ActiveModel::Type::String"
        }
      ],
      :validators: [
        {
          :name: "add_another_a_level",
          :class: "ActiveModel::Validations::PresenceValidator",
          :type: "presence",
          :message: null
        },
        {
          :name: "add_another_a_level",
          :class: "ActiveModel::Validations::InclusionValidator",
          :type: "inclusion",
          :message: null
        }
      ],
      :operations: [
        {
          :name: "validate",
          :description: "Validate operation"
        },
        {
          :name: "persist",
          :description: "Persist operation"
        }
      ]
    },
    :remove_a_level_subject_confirmation: {
      :class: "ALevelSteps::RemoveALevelSubjectConfirmation",
      :label: "Remove A Level Subject Confirmation",
      :attributes: [
        {
          :name: "uuid",
          :type: "ActiveModel::Type::String"
        },
        {
          :name: "confirmation",
          :type: "ActiveModel::Type::String"
        }
      ],
      :validators: [
        {
          :name: "uuid",
          :class: "ActiveModel::Validations::PresenceValidator",
          :type: "presence",
          :message: null
        }
      ],
      :operations: [
        {
          :name: "validate",
          :description: "Validate operation"
        },
        {
          :name: "persist",
          :description: "Persist operation"
        }
      ]
    },
    :consider_pending_a_level: {
      :class: "ALevelSteps::ConsiderPendingALevel",
      :label: "Consider Pending A Level",
      :attributes: [
        {
          :name: "pending_a_level",
          :type: "ActiveModel::Type::Value"
        }
      ],
      :validators: [
        {
          :name: "pending_a_level",
          :class: "ActiveModel::Validations::PresenceValidator",
          :type: "presence",
          :message: null
        },
        {
          :name: "pending_a_level",
          :class: "ActiveModel::Validations::InclusionValidator",
          :type: "inclusion",
          :message: null
        }
      ],
      :operations: [
        {
          :name: "validate",
          :description: "Validate operation"
        },
        {
          :name: "persist",
          :description: "Persist operation"
        }
      ]
    },
    :a_level_equivalencies: {
      :class: "ALevelSteps::ALevelEquivalencies",
      :label: "A Level Equivalencies",
      :attributes: [
        {
          :name: "accept_a_level_equivalency",
          :type: "ActiveModel::Type::Value"
        },
        {
          :name: "additional_a_level_equivalencies",
          :type: "ActiveModel::Type::Value"
        }
      ],
      :validators: [
        {
          :name: "accept_a_level_equivalency",
          :class: "ActiveModel::Validations::PresenceValidator",
          :type: "presence",
          :message: null
        },
        {
          :name: "accept_a_level_equivalency",
          :class: "ActiveModel::Validations::InclusionValidator",
          :type: "inclusion",
          :message: null
        },
        {
          :name: "additional_a_level_equivalencies",
          :class: "WordsCountValidator",
          :type: "words_count",
          :message: {}
        }
      ],
      :operations: [
        {
          :name: "validate",
          :description: "Validate operation"
        },
        {
          :name: "persist",
          :description: "Persist operation"
        }
      ]
    }
  },
  :transitions: [
    {
      :from: "what_a_level_is_required",
      :to: "add_a_level_to_a_list",
      :type: "simple",
      :label: null
    },
    {
      :from: "remove_a_level_subject_confirmation",
      :to: "add_a_level_to_a_list",
      :type: "simple",
      :label: null
    },
    {
      :from: "consider_pending_a_level",
      :to: "a_level_equivalencies",
      :type: "simple",
      :label: null
    },
    {
      :from: "a_level_equivalencies",
      :to: "course_edit",
      :type: "simple",
      :label: null
    },
    {
      :from: "add_a_level_to_a_list",
      :when: "another_a_level_needed?",
      :then: "what_a_level_is_required",
      :else: "consider_pending_a_level",
      :type: "conditional",
      :label: null
    }
  ],
  :counts: {
    :steps: 5,
    :simple_edges: 4,
    :conditional_edges: 1,
    :multiple_conditional_edges: 0,
    :custom_branching_edges: 0
  },
  :wizard_name: "A levels wizard"
}
```

**Note:** This is the unified metadata format consumed by all documentation formatters.
