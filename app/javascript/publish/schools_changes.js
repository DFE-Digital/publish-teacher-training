// What a provider has changed about a course's schools, worked out from the
// ticks alone.
//
// The decision is kept away from the DOM so it can be read and tested on its
// own: schoolsFromCheckboxes turns the rows into plain objects, and
// schoolChanges answers what they add up to. Names travel rather than elements,
// so nothing downstream can quietly reach back into the page.

// The adapter. A school is what the row carries: what it submits, what it is
// called, and whether it is ticked. The name is an attribute of its own because
// the label may also hold the newly added tag.
export function schoolsFromCheckboxes (elements) {
  return elements.map(element => ({
    value: element.value,
    name: element.dataset.schoolName,
    checked: element.checked
  }))
}

// `attached` is what was chosen when the page was served. Every school ticked,
// or none left ticked, is better said than listed - and it is the end state that
// decides, not which control got there.
export function schoolChanges (schools, attached) {
  const alreadyOn = new Set(attached)
  const checked = schools.filter(school => school.checked)

  const adding = checked.filter(school => !alreadyOn.has(school.value))
  const removing = schools.filter(school => !school.checked && alreadyOn.has(school.value))

  return {
    adding: { names: names(adding), all: checked.length === schools.length },
    removing: { names: names(removing), all: checked.length === 0 },
    changed: adding.length > 0 || removing.length > 0
  }
}

function names (schools) {
  return schools.map(school => school.name)
}
