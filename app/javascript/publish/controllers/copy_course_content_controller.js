import { Controller } from '@hotwired/stimulus'

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

    if (!selected || !selected.value) {
      this.detailsTarget.hidden = true
      return
    }

    this.titleTarget.textContent = `${selected.dataset.name} (${selected.dataset.code})`

    this.ageTarget.textContent = selected.dataset.age || ''

    this.fundingTarget.textContent = selected.dataset.funding || ''

    this.qualificationTarget.textContent = selected.dataset.qualification || ''

    this.studyModeTarget.textContent = selected.dataset.studyMode || ''

    this.startDateTarget.textContent = selected.dataset.startDate || ''

    this.detailsTarget.hidden = false
  }
}
