import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'preview']

  updatePreview(event) {
    let previewContent = ""

    this.inputTargets.forEach(input => {
      let content = input.value

      let listContent = ""

      // Convert bullet points: * text -> <li>text</li> (removes the '*')
      content = content.replace(/^\* ([^\n]+)(?:\s*\(([^\)]+)\))?$/gm, (match, text, url) => {
        if (url) {
          listContent += `<li><a class="govuk-link" href="${url}">${text}</a></li>`
        } else {
          listContent += `<li>${text}</li>`
        }
        return "" // Remove bullet point line
      })

      if (listContent) {
        listContent = `<ul class="govuk-list govuk-list--bullet">${listContent}</ul>`
      }

      // Convert newlines to <br> and wrap in <p>
      content = content.replace(/\n/g, '<br>')
      previewContent += `<p>${content}</p>${listContent}`
    })

    this.previewTarget.innerHTML = previewContent
  }
}
