# frozen_string_literal: true

require "rails_helper"

describe WordsCountValidator do
  subject { model }

  before do
    maximum = maximum_val
    message = message_val
    message_attribute = message_attribute_val

    stub_const("Validatable", Class.new do
      include ActiveModel::Validations
      attr_accessor :some_words

      validates :some_words, words_count: { maximum:, message:, message_attribute: }
    end)

    subject.validate
  end

  let!(:maximum_val) { 10 }
  let!(:message_val) { nil }
  let!(:message_attribute_val) { nil }

  let(:model) do
    model = Validatable.new
    model.some_words = some_words_field
    model
  end

  let(:expected_errors) { ["Reduce the word count for some words"] }

  context "with max valid number of words" do
    let(:some_words_field) { (%w[word] * maximum_val).join(" ") }

    it { is_expected.to be_valid }
  end

  context "with no words" do
    let(:some_words_field) { "" }

    it { is_expected.to be_valid }
  end

  context "with nil words" do
    let(:some_words_field) { nil }

    it { is_expected.to be_valid }
  end

  context "with invalid number of words" do
    let(:some_words_field) { "#{(%w[word] * maximum_val).join(' ')} popped" }

    it { is_expected.to be_invalid }

    it "adds an error" do
      expect(model.errors[:some_words]).to match_array expected_errors
    end
  end

  context "with newlines" do
    let(:some_words_field) { "#{(%w[word] * maximum_val).join("\n")} popped" }

    it { is_expected.to be_invalid }

    it "adds an error" do
      expect(model.errors[:some_words]).to match_array expected_errors
    end
  end

  context "with non-words such as markdown" do
    let(:some_words_field) { "#{(%w[word] * maximum_val).join(' ')} *" }

    it { is_expected.to be_invalid }

    it "adds an error" do
      expect(model.errors[:some_words]).to match_array expected_errors
    end
  end

  describe "error messages" do
    let(:some_words_field) { "#{(%w[word] * maximum_val).join(' ')} popped" }

    context "with message option" do
      let(:expected_errors) { ["My custom error message!"] }

      let!(:message_val) { "My custom error message!" }

      context "with non-words such as markdown" do
        it "adds the correct error" do
          expect(model.errors[:some_words]).to match_array expected_errors
        end
      end
    end

    context "with message_attribute option" do
      let(:expected_errors) { ["Reduce the word count for append this to the standard message"] }

      let!(:message_attribute_val) { "append this to the standard message" }

      context "with non-words such as markdown" do
        it "adds the correct error" do
          expect(model.errors[:some_words]).to match_array expected_errors
        end
      end
    end
  end
end
