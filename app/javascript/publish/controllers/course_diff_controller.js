import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["summary", "addedSection", "removedSection"];

  static values = {
    initialCourseIds: String,
  };

  // connect() {
  //   this.initialIds = new Set(
  //     this.initialCourseIdsValue.split(",").filter(Boolean).map(Number),
  //   );

  //   this.update();
  // }

  connect() {
    console.log("course-selection-summary connected");

    this.initialIds = new Set(
      this.initialCourseIdsValue.split(",").filter(Boolean).map(Number),
    );

    this.update();
  }

  update() {
    const checkboxes = Array.from(
      this.element.querySelectorAll('input[name="course_ids[]"]'),
    );

    const checked = checkboxes.filter((cb) => cb.checked);

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
          <strong>You are attaching ${added.length} course${added.length === 1 ? "" : "s"}:</strong>
        </p>
        <ul class="govuk-list govuk-list--bullet">
          ${added.map((cb) => `<li>${cb.dataset.courseName}</li>`).join("")}
        </ul>
      `;
    }

    if (removed.length > 0) {
      this.removedSectionTarget.innerHTML = `
        <p class="govuk-body govuk-!-margin-bottom-1">
          <strong>You are detaching ${removed.length} course${removed.length === 1 ? "" : "s"}:</strong>
        </p>
        <ul class="govuk-list govuk-list--bullet">
          ${removed.map((cb) => `<li>${cb.dataset.courseName}</li>`).join("")}
        </ul>
      `;
    }
  }
}
