import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'preview']

  updatePreview(event) {
    const previewMap = new Map()

    // Group inputs by their preview target (individual or shared)
    this.inputTargets.forEach(input => {
      const previewKey = input.dataset.previewOutputTarget || 'shared'

      if (!previewMap.has(previewKey)) {
        previewMap.set(previewKey, [])
      }
      previewMap.get(previewKey).push(input)
    })

    // Update each preview region
    previewMap.forEach((inputs, key) => {
      const previewEl = key === 'shared'
        ? this.previewTargets[0]
        : this.previewTargets.find(p => p.dataset.previewTarget === key)

      if (!previewEl) return

      let previewContent = ''

      inputs.forEach(input => {
        const rawContent = input.value
        const lines = rawContent.split('\n')

        // Special handling for preview2 (international fee)
        if (key === 'currency1' || key === 'currency2') {
          const sanitizedValue = rawContent.trim()
          previewContent = sanitizedValue ? `£${sanitizedValue}` : ''
          return
        }

        // Default rich preview rendering
        let blockHtml = ''
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
            text = text.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a class="govuk-link" href="$2">$1</a>')
            currentListItems.push(`<li>${text}</li>`)
          } else {
            flushList()
            if (line.trim() === '') {
              blockHtml += `<p></p>`
            } else {
              const processed = line.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a class="govuk-link" href="$2">$1</a>')
              blockHtml += `<p>${processed}</p>`
            }
          }
        })

        flushList()
        previewContent += blockHtml
      })

      previewEl.innerHTML = previewContent
    })
  }
}
