import { Controller } from '@hotwired/stimulus'

const COURSE_INFORMATION_FIELDS = [
  'age',
  'funding',
  'qualification',
  'studyMode',
  'startDate'
]

export default class extends Controller {
  static targets = [
    'details',
    'title',
    'age',
    'funding',
    'qualification',
    'studyMode',
    'startDate',
    'announcement'
  ]

  update (event) {
    const selected = event.target.selectedOptions[0]

    if (!selected?.value) {
      this.detailsTarget.hidden = true
      this.announcementTarget.textContent = ''
      return
    }
    this.detailsTarget.hidden = false

    this.titleTarget.textContent = `${selected.dataset.name} (${selected.dataset.code})`

    this.updateCourseInformation(selected)

    this.announcementTarget.textContent = ''

    // VoiceOver does not reliably announce live region updates immediately after a select change, so delay the announcement slightly to ensure the updated display is announced.
    setTimeout(() => {
      this.announcementTarget.textContent = `Additional course details displayed for ${selected.dataset.name} (${selected.dataset.code}).`
    }, 100)
  }

  updateCourseInformation (selected) {
    COURSE_INFORMATION_FIELDS.forEach((field) => {
      this[`${field}Target`].textContent = selected.dataset[field] || ''
    })
  }
}
