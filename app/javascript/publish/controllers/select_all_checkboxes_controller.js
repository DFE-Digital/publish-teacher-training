import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['selectAll', 'checkbox']

  connect () {
    this.updateSelectAll()
  }

  toggleAll (event) {
    const checked = event.target.checked
    this.checkboxTargets.forEach(box => { box.checked = checked })
    this.selectAllTarget.indeterminate = false
  }

  updateSelectAll () {
    const total = this.checkboxTargets.length
    const checkedCount = this.checkboxTargets.filter(cb => cb.checked).length

    if (checkedCount === 0) {
      this.selectAllTarget.checked = false
      this.selectAllTarget.indeterminate = false
    } else if (checkedCount === total) {
      this.selectAllTarget.checked = true
      this.selectAllTarget.indeterminate = false
    } else {
      this.selectAllTarget.checked = false
      this.selectAllTarget.indeterminate = true
    }
  }
}
