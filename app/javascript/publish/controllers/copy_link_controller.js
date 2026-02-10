import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { text: String }
  static targets = ['button']

  connect () {
    this.buttonTarget.removeAttribute('hidden')
  }

  copy (event) {
    event.preventDefault()

    navigator.clipboard
      .writeText(this.textValue)
      .then(() => {
        this.buttonTarget.textContent = 'Copied!'
        this.buttonTarget.classList.add('govuk-button--success')

        setTimeout(() => {
          this.buttonTarget.textContent = 'Copy link'
          this.buttonTarget.classList.remove('govuk-button--success')
        }, 1500)
      })
      .catch(() => {
        alert('Unable to copy link')
      })
  }
}
