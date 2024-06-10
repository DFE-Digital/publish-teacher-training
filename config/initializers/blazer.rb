# frozen_string_literal: true

Blazer::Record.pluralize_table_names = true
ENV['BLAZER_DATABASE_URL'] = ENV.fetch('DATABASE_URL', nil)
