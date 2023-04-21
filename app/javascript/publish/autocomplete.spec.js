/**
 * @jest-environment jsdom
 */

import { initAutocomplete, getPath, request } from './autocomplete'

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

  describe('getPath', () => {
    it('should return a path', () => {
      const path = getPath('/endpoint', 'queryString')
      expect(path).toBe('/endpoint?query=queryString')
    })
  })

  describe('request', () => {
    let requestFn
    const abortMock = jest.fn()

    beforeEach(() => {
      global.XMLHttpRequest = jest.fn(() => ({
        abort: abortMock,
        addEventListener: (_, cb) => cb(),
        open: jest.fn(),
        send: jest.fn(),
        responseText: '[]',
        readyState: 2
      }))
      requestFn = request('/endpoint')
    })

    it('should return a function', () => {
      expect(typeof requestFn).toBe('function')
    })

    describe('when called', () => {
      const cb = jest.fn()

      beforeEach(() => {
        requestFn('foo', cb)
      })

      it('should perform an ajax request', () => {
        expect(XMLHttpRequest).toBeCalled()
      })

      it('should invoke callback', () => {
        expect(cb).toBeCalled()
      })
    })

    describe('when called with a pending request', () => {
      const cb = jest.fn()

      beforeEach(() => {
        requestFn('foo', cb)
        requestFn('bar', cb)
      })

      it('should abort a request', () => {
        expect(abortMock).toBeCalled()
      })
    })
  })
})
