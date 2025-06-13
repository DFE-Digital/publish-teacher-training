import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['icon', 'text']
  static values = {
    savedPath: String,
    unsavedPath: String,
    userId: String,
    courseId: String
  }

  connect () {
    if (!this.hasUserIdValue) return

    this.saved = false
    this.checkSavedStatus()
  }

  async checkSavedStatus () {
    try {
      const response = await fetch(`/api/saved_courses?user_id=${this.userIdValue}&course_id=${this.courseIdValue}`, {
        credentials: 'include'
      })

      if (!response.ok) throw new Error('Failed to fetch saved status')

      const data = await response.json()
      this.saved = data.saved

      this.updateVisualState()
    } catch (error) {
      console.error('Error checking saved status:', error)
    }
  }

  toggle () {
    if (!this.hasUserIdValue) {
      window.location.href = '/'
      return
    }

    this.saved = !this.saved
    this.updateVisualState()
    this.updateSavedStatus()
  }

  async updateSavedStatus () {
    const method = this.saved ? 'POST' : 'DELETE'

    try {
      await fetch('/api/saved_courses', {
        method: method,
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          user_id: this.userIdValue,
          course_id: this.courseIdValue
        })
      })
    } catch (error) {
      console.error('Failed to update saved status:', error)
    }
  }

  updateVisualState () {
    this.iconTarget.src = this.saved ? this.savedPathValue : this.unsavedPathValue

    if (this.hasTextTarget) {
      this.textTarget.textContent = this.saved ? 'Course saved' : 'Save this course for later'
    }
  }
}
