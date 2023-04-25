/**
 * @jest-environment jsdom
 */

import { request, getPath } from "./request_helper";

describe("Request helpers", () => {

  describe("getPath", () => {
    it("should return a path", () => {
      const path = getPath("/endpoint", "queryString");
      expect(path).toBe("/endpoint?query=queryString");
    });
  });

  describe("request", () => {
    let requestFn;
    const abortMock = jest.fn();

    beforeEach(() => {
      global.XMLHttpRequest = jest.fn(() => ({
        abort: abortMock,
        addEventListener: (_, cb) => cb(),
        open: jest.fn(),
        send: jest.fn(),
        responseText: "[]",
        readyState: 2,
      }));
      requestFn = request("/endpoint");
    });

    it("should return a function", () => {
      expect(typeof requestFn).toBe("function");
    });

    describe("when called", () => {
      const cb = jest.fn();

      beforeEach(() => {
        requestFn("foo", cb);
      });

      it("should perform an ajax request", () => {
        expect(XMLHttpRequest).toBeCalled();
      });

      it("should invoke callback", () => {
        expect(cb).toBeCalled();
      });
    });

    describe("when called with a pending request", () => {
      const cb = jest.fn();

      beforeEach(() => {
        requestFn("foo", cb);
        requestFn("bar", cb);
      });

      it("should abort a request", () => {
        expect(abortMock).toBeCalled();
      });
    });
  });
});
