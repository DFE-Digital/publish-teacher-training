describe PhoneValidator do
  let(:model) do
    cls = Class.new do
      include ActiveRecord::Validations

      attr_accessor :phone_number

      validates :phone_number, phone: true
    end

    cls.new
  end

  describe 'With nil phone number address' do
    before do
      model.phone_number = nil
      model.validate(:no_context)
    end

    it 'Returns invalid' do
      expect(model.valid?(:no_context)).to be false
    end

    it 'Returns the correct error message' do
      expect(model.errors[:phone_number]).to include("^Enter a valid telephone number")
    end
  end

  describe 'With empty phone number address supplied' do
    before do
      model.phone_number = ""
      model.validate(:no_context)
    end

    it 'Returns invalid' do
      expect(model.valid?(:no_context)).to be false
    end

    it 'Returns the correct error message' do
      expect(model.errors[:phone_number]).to include("^Enter a valid telephone number")
    end
  end

  describe 'With an phone number address in an invalid format' do
    let(:invalid_telephone_numbers) do
      [
        "12 3 4 cat",
        "12dog34",
      ]
    end

    it 'Correctly invalidates invalid phone numbers' do
      invalid_telephone_numbers.each do |number|
        model.phone_number = number
        expect(model.valid?(:no_context)).to(be(false), "Expected phone number #{number} to be invalid")
      end
    end
  end

  describe 'With a valid phone number address' do
    let(:valid_telephone_numbers) do
      [
        "+447123 123 123",
        "+447123123123",
        "07123123123",
        "01234 123 123 ext123",
        "01234 123 123 ext 123",
        "01234 123 123 x123",
        "(01234) 123123",
        "(12345) 123123",
        "(+44) (0)1234 123456",
        "+44 (0) 123 4567 123",
        "123 1234 1234 ext 123",
        "12345 123456 ext 123",
        "12345 123456 ext. 123",
        "12345 123456 ext123",
        "01234123456 ext 123",
        "123 1234 1234 x123",
        "12345 123456 x123",
        "12345123456 x123",
        "(1234) 123 1234",
        "1234 123 1234 x123",
        "1234 123 1234 ext 1234",
        "1234 123 1234  ext 123",
        "+44(0)123 12 12345",
      ]
    end

    it 'Correctly validates valid phone numbers' do
      valid_telephone_numbers.each do |number|
        model.phone_number = number
        expect(model.valid?(:no_context)).to(be(true), "Expected phone number #{number} to be valid")
      end
    end
  end
end
