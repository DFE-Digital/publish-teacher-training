describe EmailValidator do
  let(:model) { ExampleModel.new }

  describe 'With nil email address' do
    before do
      model.email = nil
      model.validate(:no_context)
    end

    it 'Returns invalid' do
      expect(model.valid?(:no_context)).to be false
    end

    it 'Returns the correct error message' do
      expect(model.errors[:email]).to include("^Enter an email address in the correct format, like name@example.com")
    end
  end

  describe 'With empty email address supplied' do
    before do
      model.email = ""
      model.validate(:no_context)
    end

    it 'Returns invalid' do
      expect(model.valid?(:no_context)).to be false
    end

    it 'Returns the correct error message' do
      expect(model.errors[:email]).to include("^Enter an email address in the correct format, like name@example.com")
    end
  end

  describe 'With an email address in an invalid format' do
    before do
      model.email = "cats4lyf"
      model.validate(:no_context)
    end

    it 'Returns invalid' do
      expect(model.valid?(:no_context)).to be false
    end

    it 'Returns the correct error message' do
      expect(model.errors[:email]).to include("^Enter an email address in the correct format, like name@example.com")
    end
  end

  describe 'With a valid email address' do
    it 'Returns valid' do
      model.email = "cats@meow.cat"
      model.validate(:no_context)

      expect(model.valid?(:no_context)).to be true
    end
  end

private

  class ExampleModel
    include ActiveRecord::Validations

    attr_accessor :email

    validates :email, email: true
  end
end
