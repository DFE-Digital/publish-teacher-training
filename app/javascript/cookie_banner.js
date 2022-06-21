import {
  getCookie,
  setCookie
} from './utils/cookie_helper'

export default class CookieBanner {
  static init () {
    return new CookieBanner()
  }

  constructor () {
    if (this.isConsentAnswerRequired()) {
      this.$banner = document.querySelector('[data-module="govuk-cookie-banner"]')

      if (!this.$banner) return

      this.cookieName = this.$banner.attributes['data-cookie-consent-name'].value
      this.expiryAfterDays = this.$banner.attributes['data-cookie-consent-expiry-after-days'].value
      this.$afterConsentBanner = document.querySelector('[data-module="govuk-cookie-after-consent-banner"]')

      this.$acceptButton = this.$banner.querySelector('[value="yes"]')
      this.$rejectButton = this.$banner.querySelector('[value="no"]')
      this.$hideButton = this.$afterConsentBanner.querySelector('button')

      this.bindEvents()
    }
  }

  bindEvents () {
    this.$acceptButton.addEventListener('click', () => this.accept())
    this.$rejectButton.addEventListener('click', () => this.reject())
    this.$hideButton.addEventListener('click', () => this.hideAfterConsentBanner())
  }

  isConsentAnswerRequired () {
    return getCookie(this.cookieName) === null
  }

  saveAnswer (answer) {
    setCookie(this.cookieName, answer, { days: this.expiryAfterDays })
    this.hideBanner()
    this.$afterConsentBanner.setAttribute('data-consented', answer)
    this.showAfterConsentBanner()
  }

  accept () {
    this.saveAnswer(this.$acceptButton.value)
  }

  reject () {
    this.saveAnswer(this.$rejectButton.value)
  }

  hideBanner () {
    this.$banner.hidden = true
  }

  showAfterConsentBanner () {
    this.$afterConsentBanner.hidden = false
  }

  hideAfterConsentBanner () {
    this.$afterConsentBanner.hidden = true
  }
}
