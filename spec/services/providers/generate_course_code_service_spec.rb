# frozen_string_literal: true

require "rails_helper"

describe Providers::GenerateCourseCodeService do
  let(:service) { described_class.new }

  it "returns a course code like A000" do
    expect(service.execute).to match(/^[A-Z]\d{3}$/)
  end

  it "does not include O" do
    expect(service.send(:valid_letters)).not_to include("O")
  end

  it "does not include I" do
    expect(service.send(:valid_letters)).not_to include("I")
  end

  it "does not include lower case letters" do
    letters_string = service.send(:valid_letters).join(" ")

    expect(letters_string).not_to match(/[a-z]/)
  end

  it "does not include I" do
    expect(service.send(:valid_number)).to match(/^\d{3}$/)
  end

  it 'calls "valid_number once' do
    expect(service).to receive(:valid_number).once.and_return("111")

    service.execute
  end
end
