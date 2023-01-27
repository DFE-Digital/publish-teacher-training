# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  retry_on ActiveRecord::Deadlocked

  discard_on ActiveJob::DeserializationError
end
