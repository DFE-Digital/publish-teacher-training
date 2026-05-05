import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "school"]

  search(event) {
    // Stop Enter from submitting the whole form
    if (event) event.preventDefault()

    const query = this.inputTarget.value.trim().toLowerCase()

    this.schoolTargets.forEach((element) => {
      const text = element.dataset.searchText || ""

      if (query === "" || text.includes(query)) {
        element.classList.remove("govuk-!-display-none")
      } else {
        element.classList.add("govuk-!-display-none")
      }
    })
  }
}
