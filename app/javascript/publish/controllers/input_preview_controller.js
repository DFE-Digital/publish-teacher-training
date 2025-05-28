import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'preview']

  updatePreview(event) {
    let previewContent = ""

    this.inputTargets.forEach(input => {
      const contentWithLineBreaks = input.value.replace(/\n/g, '<br>')

      previewContent += `<p>${contentWithLineBreaks}</p>`
    })

    this.previewTarget.innerHTML = previewContent
  }
}
