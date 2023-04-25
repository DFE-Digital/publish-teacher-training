/**
 * @jest-environment jsdom
 */

import { initAutocomplete } from './autocomplete'

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
      const schoolInput = document.getElementById('input')
      const schoolAutocomplete = document.getElementById('autocomplete-container')

      initAutocomplete(
        schoolAutocomplete,
        schoolInput,
        schoolTemplate,
        { path: '/endpoint' }
      )
    })

    it('should instantiate an autocomplete', () => {
      expect(document.querySelector('#outer-container')).toMatchSnapshot()
    })
  })
})
