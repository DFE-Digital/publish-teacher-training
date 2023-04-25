/**
 * @jest-environment jsdom
 */

import initAutocomplete from './autocomplete'

describe('Autocomplete', () => {
  describe('initAutocomplete', () => {
    beforeEach(() => {
      document.body.innerHTML = `
         <div id="outer-container">
           <input type="text" id="input">
           <div id="autocomplete-container"></div>
         </div>
       `

      initAutocomplete(
        {
          element: 'autocomplete-container',
          input: 'input',
          path: '/endpoint'
        }
      )
    })

    it('should instantiate an autocomplete', () => {
      expect(document.querySelector('#outer-container')).toMatchSnapshot()
    })
  })
})
