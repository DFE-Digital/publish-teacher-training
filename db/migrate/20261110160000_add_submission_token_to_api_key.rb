# frozen_string_literal: true

class AddSubmissionTokenToAPIKey < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :api_key, :submission_token, :uuid
    add_index :api_key, :submission_token, unique: true, algorithm: :concurrently
  end
end
