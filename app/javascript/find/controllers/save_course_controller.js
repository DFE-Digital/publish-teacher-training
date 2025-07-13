import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['icon', 'text']
  static values = {
    courseId: String,
    saved: Boolean,
    saveUrl: String,
    unsaveUrl: String,
    savedIconUrl: String,
    unsavedIconUrl: String
  }

  toggle (event) {
    event.preventDefault()
    this.setLoadingState(true)

    if (this.savedValue) {
      this.unsave()
    } else {
      this.save()
    }
  }

  async save () {
    try {
      const body = this.buildFormBody({ course_id: this.courseIdValue })

      const response = await fetch(this.saveUrlValue, {
        method: 'POST',
        headers: this.headers(),
        body
      })

      if (response.ok) {
        const json = await response.json()
        this.unsaveUrlValue = `/candidate/saved-courses/${json.saved_course}`
        this.updateUI(true)
      }
    } catch (e) {
      console.error('Save failed:', e)
    } finally {
      this.setLoadingState(false)
    }
  }

  async unsave () {
    try {
      const response = await fetch(this.unsaveUrlValue, {
        method: 'DELETE',
        headers: this.headers(),
        body: this.buildFormBody()
      })

      if (response.ok) {
        this.unsaveUrlValue = ''
        this.updateUI(false)
      }
    } catch (e) {
      console.error('Unsave failed:', e)
    } finally {
      this.setLoadingState(false)
    }
  }

  updateUI (saved) {
    this.savedValue = saved

    this.iconTarget.src = saved ? this.savedIconUrlValue : this.unsavedIconUrlValue
    this.iconTarget.alt = saved ? 'Saved' : 'Save'
    this.textTarget.textContent = saved ? 'Saved' : 'Save'
  }

  setLoadingState (disabled) {
    this.iconTarget.closest('button').disabled = disabled
  }

  buildFormBody (extraParams = {}) {
    return new URLSearchParams({
      ...extraParams,
      authenticity_token: this.csrfToken()
    })
  }

  csrfToken () {
    return document.querySelector('meta[name="csrf-token"]')?.content || ''
  }

  headers () {
    return {
      'X-CSRF-Token': this.csrfToken(),
      Accept: 'application/json'
    }
  }
}
