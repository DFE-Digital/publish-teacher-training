import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'preview']

  updatePreview () {
    this.previewTargets.forEach(previewTarget => {
      previewTarget.innerText = this.inputTarget.value
    })
  }
}
