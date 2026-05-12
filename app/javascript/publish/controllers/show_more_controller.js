import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["item", "button"];
  static values = { pageSize: Number };

  connect() {
    this.visibleCount = this.pageSizeValue;
    this.update();
  }

  showMore(event) {
    if (event) event.preventDefault();

    this.visibleCount += this.pageSizeValue;
    this.update();
  }

  update() {
    this.itemTargets.forEach((item, index) => {
      item.hidden = index >= this.visibleCount;
    });

    this.buttonTarget.hidden = this.visibleCount >= this.itemTargets.length;
  }
}
