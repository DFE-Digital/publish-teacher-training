describe WordsCountValidator do
  let(:max_words_count) { 10 }
  let(:upper_bounds) { (%w[word] * max_words_count).join(' ') }
  before do
    stub_const("Validatable", Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :some_words
      validates :some_words, words_count: { max_words_count: 10 }
    end
  end


  subject { Validatable.new }

  it {
    expect(subject).to be_valid
  }

  context "with valid number of words" do
    it 'valid' do
      subject.some_words = upper_bounds
      expect(subject).to be_valid
    end
  end


  context 'with invalid number of words' do
    it 'adds an error' do
      subject.some_words = upper_bounds + ' popped'
      expect(subject).not_to be_valid
      expect(subject.errors[:some_words]).not_to be_blank
    end
  end
end
