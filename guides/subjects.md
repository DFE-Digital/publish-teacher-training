# Subjects

Courses have subjects. The Subject model uses Single Table Inheritance (STI).

### Subject types

| Type | Description |
|------|-------------|
| `PrimarySubject` | Primary level subjects (e.g. Primary, Primary with English) |
| `SecondarySubject` | Secondary level subjects (e.g. English, Physics, Modern Languages, Design and technology) |
| `ModernLanguagesSubject` | Individual languages (e.g. French, Mandarin) — children of the Modern Languages `SecondarySubject` |
| `DesignTechnologySubject` | D&T specialisms (e.g. Engineering, Food technology) — children of the Design and technology `SecondarySubject` |
| `FurtherEducationSubject` | Further education (single instance) |
| `DiscontinuedSubject` | Legacy subjects no longer in use (Humanities, Balanced Science, English as a second or other language) |

### Association

```
Course => CourseSubject => Subject
```

`CourseSubject` is a join table with a `position` column that determines subject ordering.

Course has:
- `master_subject_id` — the primary subject for the course, stored as a column on the course table
- `subordinate_subject_id` — a virtual attribute, derived at runtime as the second `SecondarySubject` by position

### Positioning

The `position` column on `CourseSubject` controls the order of subjects on a course. The sorting rules are:

1. **Master subject** at position 0
2. **Master's children** — if master is a parent subject (Modern Languages or Design and technology), its child subjects follow immediately
3. **Remaining subjects** — everything else, with any parent-child groupings kept together (parent before children)

### Parent-child relationships

Two subjects act as parents with STI child types:

| Parent (`SecondarySubject`) | Child type | Examples |
|-----------------------------|------------|----------|
| Modern Languages | `ModernLanguagesSubject` | French, Mandarin, German, Spanish, etc. |
| Design and technology | `DesignTechnologySubject` | Engineering, Product design, Food technology, Textiles, Graphics |

### Subordinate subject derivation

`subordinate_subject_id` is not stored in the database. It is derived from the positioned course subjects by filtering to only `SecondarySubject` types and taking the second one.

This means child types (`ModernLanguagesSubject`, `DesignTechnologySubject`) are skipped in the derivation — they never count as the subordinate.

Examples:

| Positions | SecondarySubjects in order | subordinate_subject_id |
|-----------|---------------------------|----------------------|
| Physics, English | Physics, English | English |
| Modern Languages, French, Mandarin, Physics | Modern Languages, Physics | Physics |
| Design and technology, Engineering, Physics | Design and technology, Physics | Physics |
| Modern Languages, French, Design and technology, Engineering | Modern Languages, Design and technology | Design and technology |
| English | English | nil |

### Modern Languages

The `SecondarySubject` "Modern Languages" is a generic parent. A course with this as its master subject will also have one or more `ModernLanguagesSubject` records (French, Mandarin, etc.) as children on the course.

When subjects are assigned via `Courses::AssignSubjectsService`, language children are automatically positioned after the Modern Languages parent.

### Design and technology

Works the same way as Modern Languages. The `SecondarySubject` "Design and technology" is the parent, with `DesignTechnologySubject` specialisms as children.
