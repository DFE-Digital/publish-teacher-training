import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'preview']

  updatePreview(event) {
    let previewContent = ""

    this.inputTargets.forEach(input => {
      const rawContent = input.value
      const lines = rawContent.split('\n')

      let blockHtml = ""
      let currentListItems = []

      const flushList = () => {
        if (currentListItems.length > 0) {
          blockHtml += `<ul class="govuk-list govuk-list--bullet">${currentListItems.join('')}</ul>`
          currentListItems = []
        }
      }

      lines.forEach(line => {
        const bulletMatch = line.match(/^\* (.+)$/)
        if (bulletMatch) {
          let text = bulletMatch[1]

          text = text.replace(
            /\[([^\]]+)\]\(([^)]+)\)/g,
            '<a class="govuk-link" href="$2">$1</a>'
          )

          currentListItems.push(`<li>${text}</li>`)
        } else {
          flushList()

          if (line.trim() === '') {
            blockHtml += `<p></p>`
          } else {
            const processed = line.replace(
              /\[([^\]]+)\]\(([^)]+)\)/g,
              '<a class="govuk-link" href="$2">$1</a>'
            )
            blockHtml += `<p>${processed}</p>`
          }
        }
      })

      flushList()
      previewContent += blockHtml
    })

    this.previewTarget.innerHTML = previewContent
  }
}
