module.exports = {
  moduleDirectories: ['node_modules', 'app/javascript'],
  moduleFileExtensions: ['js', 'ts'],
  automock: false,
  resetMocks: true,
  transform: { '^.+\\.(js)?$': 'babel-jest' },
  cacheDirectory: '<rootDir>/.jest-cache',
  collectCoverage: true,
  coverageDirectory: 'coverage/frontend',
  coverageReporters: ['text', 'lcov'],
  collectCoverageFrom: [
    '<rootDir>/app/javascript/**/*.js',
    '!<rootDir>/app/javascript/**/index.js',
    '!<rootDir>/app/javascript/**/application.js',
    '!<rootDir>/app/javascript/utils/test.js'
  ],
  reporters: ['default'],
  transformIgnorePatterns: ['node_modules/*'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/app/javascript/$1'
  },
  roots: ['app/javascript'],
  testEnvironment: 'jsdom',
  testMatch: ['**/app/javascript/**/*.spec.(js|ts)'],
  testURL: 'http://localhost/',
  testPathIgnorePatterns: []
}
