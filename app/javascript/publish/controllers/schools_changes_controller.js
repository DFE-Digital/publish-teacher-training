import { Controller } from '@hotwired/stimulus'

// The play-back under a list of school checkboxes: which schools the provider
// is adding to the course, and which they are taking off it, named as they tick.
//
// It owns nothing but the summary. Which rows are on screen is schools-list's,
// what the Select all checkbox does to them is select-all-checkboxes'; this only
// ever reads the ticks and says what they add up to.
//
// It reads every school, including the ones a search or the collapse has hidden.
// Those rows keep their ticks and are still submitted, so leaving them out would
// play back something other than what is about to be saved.
//
// One delegated action on the element covers both ways the selection moves.
// Clicking a school's box fires a change that bubbles up to here; Select all
// sets the other boxes programmatically, which fires nothing on them, but its
// own change bubbles too.
export default class extends Controller {
  static targets = ['summary', 'added', 'removed']
  // The schools attached when the page was served, which is what the ticks are
  // measured against. The server has to say: after a validation error the form
  // comes back holding what was submitted, so the boxes no longer remember it.
  static values = { attached: Array }

  connect () {
    this.update()
  }

  update () {
    // Stimulus connects an element as soon as the parser reaches it, which can be
    // before its children exist - and the summary is the last of them.
    if (!this.hasSummaryTarget) return

    const schools = this.schools()
    const attached = new Set(this.attachedValue)

    const checked = schools.filter(school => school.checked)

    const added = checked.filter(school => !attached.has(school.value))
    const removed = schools.filter(school => !school.checked && attached.has(school.value))

    this.summaryTarget.hidden = added.length === 0 && removed.length === 0

    // Every school ticked, or none left ticked, is better said than listed - and
    // it is the end state that decides, not which control got them there.
    this.fill(this.addedTarget, added, checked.length === schools.length)
    this.fill(this.removedTarget, removed, checked.length === 0)
  }

  schools () {
    return Array.from(this.element.querySelectorAll('input[type=checkbox][data-school-name]'))
  }

  fill (section, schools, all) {
    section.replaceChildren()

    if (schools.length === 0) return

    section.append(this.wording(section, schools.length, all))

    if (!all) section.append(this.list(schools))
  }

  // {count} is substituted here rather than by I18n, since the count is only
  // known once the provider has finished ticking.
  //
  // A count heads the list of schools that follows it, so it is a heading - the
  // page already has an h2 over both halves, and a bold paragraph would leave a
  // screen reader with two lists and nothing to tell them apart. An "all" of
  // either kind rules the other half out, so it heads nothing and stays a
  // sentence.
  wording (section, count, all) {
    if (all) {
      const paragraph = document.createElement('p')

      paragraph.className = 'govuk-body'
      paragraph.textContent = section.dataset.all

      return paragraph
    }

    const heading = document.createElement('h3')

    heading.className = 'govuk-heading-s'
    heading.textContent = count === 1
      ? section.dataset.one
      : section.dataset.other.replaceAll('{count}', count)

    return heading
  }

  // Built as nodes rather than as markup, because a school name is text the
  // provider entered and plenty of them hold an & or an apostrophe.
  list (schools) {
    const list = document.createElement('ul')

    list.className = 'govuk-list govuk-list--bullet'

    schools.forEach(school => {
      const item = document.createElement('li')

      item.textContent = school.dataset.schoolName
      list.append(item)
    })

    return list
  }
}
