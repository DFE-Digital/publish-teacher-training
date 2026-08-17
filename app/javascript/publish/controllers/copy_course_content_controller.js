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
    'startDate'
  ]

  update (event) {
    const selected = event.target.selectedOptions[0]

    if (!selected?.value) {
      this.detailsTarget.hidden = true
      return
    }

    this.titleTarget.textContent = `${selected.dataset.name} (${selected.dataset.code})`

    this.updateCourseInformation(selected)

    this.detailsTarget.hidden = false
  }

  updateCourseInformation (selected) {
    COURSE_INFORMATION_FIELDS.forEach((field) => {
      this[`${field}Target`].textContent = selected.dataset[field] || ''
    })
  }
}
