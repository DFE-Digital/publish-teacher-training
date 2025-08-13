import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  // Define "input" and "preview" as Stimulus targets.
  // Stimulus will create this.inputTargets and this.previewTargets for us,
  // allowing easy access to all matching elements [oai_citation:1‡stimulus.hotwired.dev](https://stimulus.hotwired.dev/reference/targets#:~:text=Kind%20Name%20Value%20Singular%20%60this.,a%20matching%20target%20in%20scope).
  static targets = ['input', 'preview']

  /**
  * Initialize the preview immediately so empty placeholders render on load.
  */
  connect () {
    this.updatePreview()
  };

  // This method updates the preview content. It should be triggered by an input event.
  updatePreview (event) {
    // Use a Map to group inputs by their preview target key.
    // Key will be either a specific target name (e.g., "currency1") or "shared".
    const previewMap = new Map()

    // Group inputs by their preview target (individual or shared).
    this.inputTargets.forEach(input => {
      // Each input can declare a data attribute for its preview target.
      // If `data-preview-output-target` is set on the input, use that; otherwise use 'shared'.
      const previewKey = input.dataset.previewOutputTarget || 'shared'

      // Initialize an array for this key in the map if not already present.
      if (!previewMap.has(previewKey)) {
        previewMap.set(previewKey, [])
      }
      // Add the current input element to the array for this previewKey.
      previewMap.get(previewKey).push(input)
    })

    // Now we have a map of preview keys to their associated input elements.
    // Next, update each preview region with the combined content of its inputs.
    previewMap.forEach((inputs, key) => {
      // Determine the preview element corresponding to this key.
      // Instead of assuming the first preview target is 'shared',
      // explicitly find the preview element by its matching data-preview-target attribute.
      const previewEl = this.previewTargets.find(p => p.dataset.previewTarget === key)

      // If no corresponding preview element exists, skip this group.
      if (!previewEl) return

      // We'll build the HTML content for this preview element in this string.
      let previewContent = ''

      // Go through each input in the group and process its text content.
      inputs.forEach(input => {
        const rawContent = input.value // The raw text from the input field.
        const lines = rawContent.split('\n') // Split the text into lines for processing.

        // **Special case**: If this preview is for currency fields (identified by keys 'currency1' or 'currency2'),
        // simply prefix the value with '£' (British Pound sign) and ignore other formatting rules.
        if (key === 'currency1' || key === 'currency2') {
          const sanitizedValue = rawContent.trim()
          // If there's a value, prefix it with £; if not, leave it blank.
          previewContent = sanitizedValue ? `£${sanitizedValue}` : ''
          return // Skip further processing for currency fields.
        }

        // **Default case**: Render rich text preview with basic formatting.
        // We'll accumulate HTML in blockHtml for this input, then append to previewContent.
        let blockHtml = ''
        let currentListItems = [] // Temporarily hold `<li>` items if we're in a bullet list context.

        // Helper function to flush any collected list items into a `<ul>` block.
        const flushList = () => {
          if (currentListItems.length > 0) {
            // Wrap collected list items in a UL with GOV.UK styling classes.
            blockHtml += `<ul class="govuk-list govuk-list--bullet">${currentListItems.join('')}</ul>`
            currentListItems = [] // Reset list item collection after flushing.
          }
        }

        // Process each line of the input text.
        lines.forEach(line => {
          // Check if the line starts with "* " indicating a bullet point (markdown-style list).
          const bulletMatch = line.match(/^\* (.+)$/)
          if (bulletMatch) {
            // This line is a bullet list item.
            // bulletMatch[1] contains the text after "* ".
            let text = bulletMatch[1]
            // Convert any [link text](URL) to an anchor tag with govuk-link class.
            // This regex finds markdown links and replaces with <a href="URL">text</a>.
            text = text.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a class="govuk-link" href="$2">$1</a>')
            // Add the formatted text as a list item.
            currentListItems.push(`<li>${text}</li>`)
            // (Note: We don't flush here because consecutive bullets stay in the same list.)
          } else {
            // This line is NOT a bullet point.
            // First, flush any pending list items to close off the previous list, if one was open.
            flushList()

            if (line.trim() === '') {
              // If the line is blank (only whitespace), preserve an empty paragraph for spacing.
              blockHtml += '<p></p>'
            } else {
              // For a normal line of text, convert markdown-style links to <a> tags as above.
              const processedLine = line.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a class="govuk-link" href="$2">$1</a>')
              // Wrap the line in a paragraph tag.
              blockHtml += `<p>${processedLine}</p>`
            }
          }
        })

        // After iterating through lines, flush any remaining list items to close the final list (if any).
        flushList()

        // Append this input's processed HTML block to the overall preview content.
        previewContent += blockHtml
      })

      // If the preview content is empty after processing, we can set a default message.
      const previewContentWithoutTags = previewContent.replace(/<[^>]*>/g, '')
      if (previewContentWithoutTags === '') {
        previewContent = '<p>The text you type above will show here.</p>'
      };
      // Finally, update the preview element's HTML with the compiled content.
      previewEl.innerHTML = previewContent
    })
  }
}
