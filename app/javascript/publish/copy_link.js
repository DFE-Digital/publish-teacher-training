// Reveal copy button for JS users and hide it for non-JS users
document.querySelectorAll('.copy-btn[hidden]').forEach((btn) => {
  btn.removeAttribute('hidden')
})

// Copy to clipboard functionality
document.addEventListener('click', function (event) {
  if (event.target.matches('.copy-btn')) {
    event.preventDefault()
    // Get the text to copy from the data attribute of the clicked button
    const textToCopy = event.target.dataset.copyText

    // Use the Clipboard API to copy text to the clipboard
    navigator.clipboard
      .writeText(textToCopy)
      .then(() => {
        event.target.textContent = 'Copied!'

        // Revert the button text and style after a short delay
        setTimeout(() => {
          event.target.textContent = 'Copy link'
          event.target.classList.remove('govuk-button--success')
        }, 1500)
      })
      .catch(() => {
        alert('Unable to copy the link')
      })
  }
})
