import CookieBanner from './cookie_banner'

const cookieName = '_consented_to_analytics_cookies'

const templateHTML = `
<div>
  <div class="govuk-cookie-banner" role="region" aria-label="Cookie banner" data-module="govuk-cookie-banner"
      data-cookie-consent-name=${cookieName} data-cookie-consent-expiry-after-days="182">
    <div class="govuk-cookie-banner__message govuk-width-container">
      <div class="govuk-button-group">
        <button value="yes">Accept analytics cookies</button>
        <button value="no">Reject analytics cookies</button>
      </div>
    </div>
  </div>
  <div class="govuk-cookie-banner" role="region" aria-label="Cookie banner" hidden="true"
    data-module="govuk-cookie-after-consent-banner">
      <button type="button" class="govuk-button">Hide this message</button>
  </div>
</div>`

describe('CookieBanner', () => {
  beforeEach(() => {
    document.body.innerHTML = templateHTML
  })

  describe('constructor', () => {
    afterEach(() => {
      jest.clearAllMocks()
    })

    it("doesn't run if cookie banner is not rendered by backend", () => {
      document.body.innerHTML = ''
      const banner = CookieBanner.init()
      expect(banner.$banner).toBeNull()
    })

    describe('scenario where user has not given consent', () => {
      beforeEach(() => {
        jest.spyOn(CookieBanner.prototype, 'isConsentAnswerRequired').mockImplementation(() => true)
      })

      describe('clicking accept', () => {
        it("it stores the user's answer on the cookie and hides banner", () => {
          const banner = CookieBanner.init()
          banner.$acceptButton.click()
          expect(document.cookie).toEqual(`${cookieName}=yes`)
          expect(banner.$banner.hidden).toBeTruthy()
          expect(banner.$afterConsentBanner.hidden).toBeFalsy()
        })
      })

      describe('clicking reject', () => {
        it("it stores the user's answer on the cookie and hides banner", () => {
          const banner = CookieBanner.init()
          banner.$rejectButton.click()
          expect(document.cookie).toEqual(`${cookieName}=no`)
          expect(banner.$banner.hidden).toBeTruthy()
          expect(banner.$afterConsentBanner.hidden).toBeFalsy()
        })
      })

      describe('clicking hide message', () => {
        it('it hides the after consent banner', () => {
          const banner = CookieBanner.init()
          banner.$hideButton.click()
          expect(banner.$afterConsentBanner.hidden).toBeTruthy()
        })
      })
    })
  })
})
