# frozen_string_literal: true

require "rails_helper"

module Authentications
  RSpec.describe DfESignInOmniAuth do
    subject(:omni_auth) { described_class.new }

    describe "#options" do
      it "uses the email/profile scope so values are space separated" do
        expect(omni_auth.options[:scope]).to eq(%i[email profile])
      end
    end
  end
end
