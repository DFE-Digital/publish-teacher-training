/**
 * @jest-environment jsdom
 */

import init from './provider'

describe('Provider', () => {
  describe('init', () => {
    beforeEach(() => {
      document.body.innerHTML = `
         <div id="outer-container">
           <input type="text" id="provider">
           <div id="provider-autocomplete"></div>
         </div>
       `

      init()
    })

    it('should instantiate an autocomplete', () => {
      expect(document.querySelector('#outer-container')).toMatchSnapshot()
    })
  })
})
