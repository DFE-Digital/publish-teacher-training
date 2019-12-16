namespace :cc do
  desc "Set up CodeClimate test coverage reporter in CI"
  task setup: :environment do
    system("curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter")
    system("chmod +x ./cc-test-reporter")
    system("./cc-test-reporter before-build")
  end
  desc "Report test coverage to CodeClimate"
  task report: :environment do
    PREVIOUS_TEST_RESULT = ENV.fetch("AGENT_JOBSTATUS") == "Succeeded" ? 0 : 1
    system("./cc-test-reporter after-build --exit-code #{PREVIOUS_TEST_RESULT}")
  end
end
