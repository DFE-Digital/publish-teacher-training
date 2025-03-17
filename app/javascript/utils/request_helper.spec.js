/**
 * @vitest-environment jsdom
 */

import { vi, describe, expect, test, beforeEach } from 'vitest'
import { request, getPath } from './request_helper'

describe('Request helpers', () => {
  describe('getPath', () => {
    test('should return a path', () => {
      const path = getPath('/endpoint', 'queryString')
      expect(path).toBe('/endpoint?query=queryString')
    })
  })

  describe('request', () => {
    let requestFn
    const abortMock = vi.fn()

    beforeEach(() => {
      global.XMLHttpRequest = vi.fn(() => ({
        abort: abortMock,
        addEventListener: (_, cb) => cb(),
        open: vi.fn(),
        send: vi.fn(),
        responseText: '[]',
        readyState: 2
      }))
      requestFn = request('/endpoint')
    })

    test('should return a function', () => {
      expect(typeof requestFn).toBe('function')
    })

    describe('when called', () => {
      const cb = vi.fn()

      beforeEach(() => {
        requestFn('foo', cb)
      })

      test('should perform an ajax request', () => {
        expect(XMLHttpRequest).toBeCalled()
      })

      test('should invoke callback', () => {
        expect(cb).toBeCalled()
      })
    })

    describe('when called with a pending request', () => {
      const cb = vi.fn()

      beforeEach(() => {
        requestFn('foo', cb)
        requestFn('bar', cb)
      })

      test('should abort a request', () => {
        expect(abortMock).toBeCalled()
      })
    })
  })
})
