// Reveal copy button for JS users
document.querySelectorAll(".copy-btn[hidden]").forEach((btn) => {
  btn.removeAttribute("hidden");
});

// Copy to clipboard functionality
document.addEventListener("click", function (event) {
  if (event.target.matches(".copy-btn")) {
    event.preventDefault();
    const textToCopy = event.target.dataset.copyText;

    navigator.clipboard
      .writeText(textToCopy)
      .then(() => {
        event.target.textContent = "Copied!";
        event.target.classList.add("govuk-button--success");

        setTimeout(() => {
          event.target.textContent = "Copy link";
          event.target.classList.remove("govuk-button--success");
        }, 1500);
      })
      .catch(() => {
        alert("Unable to copy the link");
      });
  }
});
