/** *********************************
 * BROWSER MOCKS
 ********************************** */

Object.defineProperty(window, 'dataLayer', { value: [] })
Object.defineProperty(window, 'gtag', {
  value: () => {
    window.dataLayer.push(arguments)
  }
})
