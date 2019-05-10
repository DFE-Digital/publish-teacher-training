namespace :cc do
  TRAVIS_TEST_RESULT = ENV['TRAVIS_TEST_RESULT']

  desc 'Set up CodeClimate test coverage reporter in CI'
  task :setup do
    system('curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter')
    system('chmod +x ./cc-test-reporter')
    system('./cc-test-reporter before-build')
  end

  desc 'Report test coverage to CodeClimate'
  task :report do
    system("./cc-test-reporter after-build --exit-code #{TRAVIS_TEST_RESULT}")
  end
end
