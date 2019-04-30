describe WordsCountValidator do
  max_words_count = 10

  before do
    stub_const("Validatable", Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :some_words
      validates :some_words, words_count: { max_words_count: max_words_count }
    end
  end

  let(:model) {
    model = Validatable.new
    model.some_words = some_words_field
    model
  }

  subject! {
    model.valid?
  }

  context "with max valid number of words" do
    let(:some_words_field) { (%w[word] * max_words_count).join(' ') }
    it { should be true }
  end

  context "with no words" do
    let(:some_words_field) { '' }
    it { should be true }
  end

  context "with nil words" do
    let(:some_words_field) { nil }
    it { should be true }
  end

  context 'with invalid number of words' do
    let(:some_words_field) { (%w[word] * max_words_count).join(' ') + ' popped' }

    it { should be false }
    it 'adds an error' do
      expect(model.errors[:some_words]).to match_array ['Reduce the word count for some words']
    end
  end
end
