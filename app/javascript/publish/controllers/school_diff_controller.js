import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["summary", "addedSection", "removedSection"];
  static values = {
    initialSiteIds: String,
  };

  connect() {
    this.initialIds = new Set(
      this.initialSiteIdsValue.split(",").filter(Boolean).map(Number),
    );

    this.update();
  }

  update() {
    const checkboxes = Array.from(
      this.element.querySelectorAll(
        'input[name="publish_course_school_form[site_ids][]"]',
      ),
    );

    const checked = checkboxes.filter((cb) => cb.checked);

    // detect "Select all schools" checkbox and if it's checked, show the "all schools selected" message instead of the individual added/removed lists
    const selectAllCheckbox = document.getElementById("select-all-schools");

    if (selectAllCheckbox?.checked) {
      this.summaryTarget.hidden = false;

      this.addedSectionTarget.innerHTML = `
        <p class="govuk-body">
          You are adding all schools on your list
        </p>
      `;

      this.removedSectionTarget.innerHTML = "";
      return;
    }

    const added = checked.filter(
      (cb) => !this.initialIds.has(Number(cb.value)),
    );

    const removed = checkboxes.filter(
      (cb) => this.initialIds.has(Number(cb.value)) && !cb.checked,
    );

    if (added.length === 0 && removed.length === 0) {
      this.summaryTarget.hidden = true;
      return;
    }

    this.summaryTarget.hidden = false;

    this.addedSectionTarget.innerHTML = "";
    this.removedSectionTarget.innerHTML = "";

    if (added.length > 0) {
      this.addedSectionTarget.innerHTML = `
        <p class="govuk-body govuk-!-margin-bottom-1">
          <strong>You are adding ${added.length} school${added.length === 1 ? "" : "s"}:</strong>
        </p>
        <ul class="govuk-list govuk-list--bullet">
          ${added.map((cb) => `<li>${cb.dataset.schoolName}</li>`).join("")}
        </ul>
      `;
    }

    if (removed.length > 0) {
      this.removedSectionTarget.innerHTML = `
        <p class="govuk-body govuk-!-margin-bottom-1">
          <strong>You are removing ${removed.length} school${removed.length === 1 ? "" : "s"}:</strong>
        </p>
        <ul class="govuk-list govuk-list--bullet">
          ${removed.map((cb) => `<li>${cb.dataset.schoolName}</li>`).join("")}
        </ul>
      `;
    }
  }
}
