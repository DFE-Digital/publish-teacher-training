/* global $ */
export const FilterToggleButton = class {
  constructor (options) {
    this.options = options
    this.container = this.options.toggleButton.container
  }

  setupResponsiveChecks () {
    this.mq = window.matchMedia(this.options.bigModeMediaQuery)
    this.mq.addListener($.proxy(this, 'checkMode'))
    this.checkMode(this.mq)
  }

  checkMode (mq) {
    if (mq.matches) {
      this.enableBigMode()
    } else {
      this.enableSmallMode()
    }
  }

  enableBigMode () {
    this.showMenu()
    this.removeMenuButton()
    this.removeCloseButton()
  }

  enableSmallMode () {
    this.options.filter.container.attr('tabindex', '-1')
    this.hideMenu()
    this.addMenuButton()
    this.addCloseButton()
  }

  addCloseButton () {
    if (this.options.closeButton) {
      this.closeButton = $(`
        <button class="app-filter__close" type="button">
          ${this.options.closeButton.text}
          <span class="govuk-visually-hidden"> filter menu</span>
        </button>
      `);
      this.closeButton.on('click', $.proxy(this, 'onCloseClick'))
      this.options.closeButton.container.append(this.closeButton)
    }
  }

  onCloseClick () {
    this.hideMenu()
    this.menuButton.focus()
  }

  removeCloseButton () {
    if (this.closeButton) {
      this.closeButton.remove()
      this.closeButton = null
    }
  }

  addMenuButton () {
    this.menuButton = $(`<button class="govuk-button ${this.options.toggleButton.classes}" type="button" aria-haspopup="true" aria-expanded="false">${this.options.toggleButton.showText}</button>`)
    this.menuButton.on('click', $.proxy(this, 'onMenuButtonClick'))
    this.options.toggleButton.container.append(this.menuButton)
  }

  removeMenuButton () {
    if (this.menuButton) {
      this.menuButton.remove()
      this.menuButton = null
    }
  }

  hideMenu () {
    if (this.menuButton) {
      this.menuButton.attr('aria-expanded', 'false')
      this.menuButton.text(this.options.toggleButton.showText)
    }
    this.options.filter.container.attr('hidden', true)
  }

  showMenu () {
    if (this.menuButton) {
      this.menuButton.attr('aria-expanded', 'true')
      this.menuButton.text(this.options.toggleButton.hideText)
    }
    this.options.filter.container.removeAttr('hidden')
  }

  onMenuButtonClick () {
    this.toggle()
  }

  toggle () {
    if (this.menuButton.attr('aria-expanded') === 'false') {
      this.showMenu()
      this.options.filter.container.focus()
    } else {
      this.hideMenu()
    }
  }

  init () {
    this.setupResponsiveChecks()
    if (this.options.startHidden) {
      this.hideMenu()
    }
  }
}
