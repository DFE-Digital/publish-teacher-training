/**
 * @jest-environment jsdom
 */

import setupAutocomplete from './setup-autocomplete'

describe('initACachedProvidersAutocomplete', () => {
  beforeEach(() => {
    document.body.innerHTML = `
         <div id="outer-container">
           <label for="query">Enter something</label>
           <select id="query">
             <option value>Select a option</option>
             <option value="A">A</option>
             <option value="B">B</option>
             <option value="C">C</option>
           </select>
         </div>
       `

    setupAutocomplete('query')
  })

  it('should instantiate an autocomplete', () => {
    expect(document.querySelector('#outer-container')).toMatchSnapshot()
  })
})
