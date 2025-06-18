module SystemRetryHelper
  def with_retry(max_attempts: 4, exceptions: [Selenium::WebDriver::Error::StaleElementReferenceError], delay: 1)
    attempts = 0
    begin
      yield
    rescue *exceptions => e
      attempts += 1
      raise e if attempts >= max_attempts

      pp "Retrying due to: #{e.class} - #{e.message} (attempt #{attempts}/#{max_attempts})"

      sleep delay
      retry
    end
  end
end
