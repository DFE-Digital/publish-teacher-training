import { Controller } from '@hotwired/stimulus'

const RELOADED_KEY = 'save-course-reloaded'

let reloadedAfterFailure = false

export default class extends Controller {
  static targets = ['icon', 'text']
  static values = {
    courseId: String,
    saved: Boolean,
    authenticated: Boolean,
    saveUrl: String,
    unsaveUrl: String,
    savedIconUrl: String,
    unsavedIconUrl: String,
    savedText: String,
    saveText: String,
    signInToSaveText: String,
    failedText: String
  }

  connect () {
    if (window.sessionStorage.getItem(RELOADED_KEY)) {
      window.sessionStorage.removeItem(RELOADED_KEY)
      reloadedAfterFailure = true
    }
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

      if (response.status === 401) {
        const json = await response.json()
        window.location.href = json.redirect
        return
      }

      if (response.ok) {
        const json = await response.json()
        this.unsaveUrlValue = `/candidate/saved-courses/${json.saved_course}`
        this.updateUI(true)
      } else {
        this.recover()
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
      } else {
        this.recover()
      }
    } catch (e) {
      console.error('Unsave failed:', e)
    } finally {
      this.setLoadingState(false)
    }
  }

  recover () {
    if (reloadedAfterFailure) {
      this.iconTarget.alt = this.failedTextValue
      this.textTarget.textContent = this.failedTextValue
      return
    }

    window.sessionStorage.setItem(RELOADED_KEY, 'true')
    window.location.reload()
  }

  updateUI (saved) {
    this.savedValue = saved

    let text

    if (saved) {
      text = this.savedTextValue
    } else if (this.authenticatedValue) {
      text = this.saveTextValue
    } else {
      text = this.signInToSaveTextValue
    }

    this.iconTarget.src = saved ? this.savedIconUrlValue : this.unsavedIconUrlValue
    this.iconTarget.alt = text
    this.textTarget.textContent = text
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
