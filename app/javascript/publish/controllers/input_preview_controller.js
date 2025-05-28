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
          // If a URL is provided in the parentheses, create a link
          listContent += `<li><a class="govuk-link" href="${url}">${text}</a></li>`
        } else {
          // Otherwise, just create a list item with plain text
          listContent += `<li>${text}</li>`
        }
        return "" // Remove the bullet point line after adding to listContent
      })

      // Only wrap the list items in <ul class="govuk-list govuk-list--bullet"> if listContent is not empty
      if (listContent) {
        listContent = `<ul class="govuk-list govuk-list--bullet">${listContent}</ul>`
      }

      content = content.replace(/\n/g, '<br>')
      previewContent += `${content}${listContent}`
      previewContent += `<p>&nbsp;</p>` // Empty paragraph to create a space between sections
    })

    this.previewTarget.innerHTML = previewContent
  }
}
