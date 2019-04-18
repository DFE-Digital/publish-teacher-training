# Creating Factories

* Created objects should be valid by default, so ensure that required
  associations are built/created.
* Avoid building/creating associations that aren't necessary.
* Provide a way to overide associated objects, for has_* relationships this will
  need to build associated objects by default, and add them to the parent object
  in an `after_create` hook.
* Providing a way to specify exactly what associated object(s) override the
  default is better than using `*_count` transients (more flexible).
* When creating a memoized object that is included in the creation of another
  object, use `build` to prevent secondary objects from being created.

# Using Factories

* Only create the objects you need, when memoizing (using `let`) prefer to pull
  out the object if it's already created as a part of another object, unless you
  need to create it in a specific way. eg.

```
let(:course)  { create :course }
let(:subject) { course.subject }
```

  or if a specific subject needs to be created:

```
let(:english_subject) { create :subject, :english }
let(:course)          { create :course, subjects: [english_subject] }
```
* When creating associated data, keep in mind which object is the `belongs_to`
  side. The object that has the `belongs_to` association should be the one that
  associates the two objects.
  
  Example:
  
```
# CORRECT
let(:provider) { create :provider }
let(:course)   { create :course, provider: provider }
# CORRECT
```

  If done this way, then two providers will be created in the DB, one as the
  memoized provider and second as part of the `create :course` (a course is not
  valid without a provider so the factory creates a provider for us, unless
  overidden like above):
  
```
# WRONG
let(:provider) { create :provider, courses: [course] }
let(:course)   { create :course }
# WRONG
```



* Use find_or_create for objects that should be singletons (e.g. "English"
  subject)
  

# Describe vs Context vs Feature vs Scenario

# Using 'let' and 'begin'
