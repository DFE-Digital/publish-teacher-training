# Subject priority notes

## Approach

- Create a column on the `course_subject` table called `priority`
- Assign this priority in the course controller based on the index of the course IDs
  - I.e. [Maths, English] -> Maths Prio 0, English Prio 1
- Sort based on priority in course model
- Sort based on priority in the v2 serialiser (for `build_new`)
- Sort based on priority in the course name service

## Thoughts

### Vs Main/Other/Languages

- What's the domain say? i.e. is there policy that dictacts "Main/Other" or is there no real policy that defines the importance of this

### Sorting in the model

- Works for persisted courses, but not in tests where you don't directly create a course (although it is rare we use an in memory course)
- Feels unclear as to their ordering until you look into priority, if I was new to the code base would i know/is it evident that the ordering is important?
  - Would it make sense to instead expose an additional method `subjects_in_priority_order`?
  - Not respected by jsonapi library

### Exposing/Not exposing priority on the API

```
Note: The spec does not impart meaning to order of resource identifier objects in linkage arrays 
of to-many relationships, although implementations may do that. Arrays of resource identifier objects 
may represent ordered or unordered relationships, and both types can be mixed in one response object.

https://jsonapi.org/format/#document-resource-object-linkage
```

- The JSON Api library doesn't inherently respect the ordering of subjects coming out when it's in memory (see: Build new course)
  - Feels like duplication of the logic
  - Does work for v3 though
  - Doesnt expose whether or not they are ordered in the actual response
  - As a consumer of the API - feels like there's no clear reason they're ordered

## Impact

- Would give us an ability to order the subjects intially, if we find problems further down the line we can migrate to main/other/languages

