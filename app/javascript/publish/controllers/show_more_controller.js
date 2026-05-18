import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["item", "button"];
  static values = { pageSize: Number };

  connect() {
    this.onReset = this.reset.bind(this);
    this.element.addEventListener("show-more:reset", this.onReset);
    this.visibleCount = this.pageSizeValue;
    this.update();
  }

  disconnect() {
    this.element.removeEventListener("show-more:reset", this.onReset);
  }

  showMore(event) {
    if (event) event.preventDefault();

    this.visibleCount += this.pageSizeValue;
    this.update();
  }

  reset() {
    this.visibleCount = this.pageSizeValue;
    this.update();
  }

  update() {
    this.itemTargets.forEach((item, index) => {
      item.hidden = index >= this.visibleCount;
    });

    this.buttonTarget.hidden = this.visibleCount >= this.itemTargets.length;
  }
}
