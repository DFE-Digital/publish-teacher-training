/**
 * @jest-environment jsdom
 */

import init from './school'

describe('school', () => {
  describe('init', () => {
    beforeEach(() => {
      document.body.innerHTML = `
         <div id="outer-container">
           <input type="text" id="publish-schools-search-form-query-field">
           <div id="school-autocomplete"></div>
         </div>
       `

      init()
    })

    it('should instantiate an autocomplete', () => {
      expect(document.querySelector('#outer-container')).toMatchSnapshot()
    })
  })
})
