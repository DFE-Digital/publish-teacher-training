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
      const schoolTemplate = (result) => result && `${result.name}`

      initAutocomplete(
        'autocomplete-container',
        'input',

        { path: '/endpoint', template: { inputValue: schoolTemplate, suggestion: schoolTemplate } }
      )
    })

    it('should instantiate an autocomplete', () => {
      expect(document.querySelector('#outer-container')).toMatchSnapshot()
    })
  })
})
