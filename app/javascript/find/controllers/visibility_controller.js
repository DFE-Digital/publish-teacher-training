import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['container', 'trigger']
  static classes = ['visible']

  show () {
    this.containerTargets.forEach((target) => {
      target.classList.add(...this.visibleClasses)
    })

    this.triggerTargets.forEach((target) => {
      target.ariaExpanded = true
    })
  }

  hide () {
    this.containerTargets.forEach((target) => {
      target.classList.remove(...this.visibleClasses)
    })

    this.triggerTargets.forEach((target) => {
      target.ariaExpanded = false
    })
  }
}
