require "rails_helper"

describe WordsCountValidator do
  maximum = 10

  before do
    stub_const("Validatable", Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :some_words
      validates :some_words, words_count: { maximum: }
    end
  end

  let(:model) do
    model = Validatable.new
    model.some_words = some_words_field
    model
  end

  let(:expected_errors) { ["^Reduce the word count for some words"] }

  subject! do
    model.valid?
  end

  context "with max valid number of words" do
    let(:some_words_field) { (%w[word] * maximum).join(" ") }

    it { is_expected.to be true }
  end

  context "with no words" do
    let(:some_words_field) { "" }

    it { is_expected.to be true }
  end

  context "with nil words" do
    let(:some_words_field) { nil }

    it { is_expected.to be true }
  end

  context "with invalid number of words" do
    let(:some_words_field) { "#{(%w[word] * maximum).join(' ')} popped" }

    it { is_expected.to be false }

    it "adds an error" do
      expect(model.errors[:some_words]).to match_array expected_errors
    end
  end

  context "with newlines" do
    let(:some_words_field) { "#{(%w[word] * maximum).join("\n")} popped" }

    it { is_expected.to be false }

    it "adds an error" do
      expect(model.errors[:some_words]).to match_array expected_errors
    end
  end

  context "with non-words such as markdown" do
    let(:some_words_field) { "#{(%w[word] * maximum).join(' ')} *" }

    it { is_expected.to be false }

    it "adds an error" do
      expect(model.errors[:some_words]).to match_array expected_errors
    end
  end
end
