/**
 * @jest-environment jsdom
 */

import init from './accredited_provider'

describe('Accredited provider', () => {
  describe('init', () => {
    beforeEach(() => {
      document.body.innerHTML = `
         <div id="outer-container">
           <input type="text" id="accredited-provider-search-form-query-field">
           <input type="text" id="accredited_provider_search_form_recruitment_cycle_year" value="2023">
           <div id="accredited-provider-autocomplete"></div>
         </div>
       `

      init()
    })

    it('should instantiate an autocomplete', () => {
      expect(document.querySelector('#outer-container')).toMatchSnapshot()
    })
  })
})
