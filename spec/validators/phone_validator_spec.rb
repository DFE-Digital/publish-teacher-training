# frozen_string_literal: true

require 'rails_helper'

class PhoneValidatorTest
  include ActiveRecord::Validations

  attr_accessor :phone_number

  validates :phone_number, phone: true
end

describe PhoneValidator do
  let(:model) do
    PhoneValidatorTest.new
  end

  context 'when nil' do
    before do
      model.phone_number = nil
      model.validate(:no_context)
    end

    it 'returns invalid' do
      expect(model.valid?(:no_context)).to be false
    end
  end

  context 'when empty' do
    before do
      model.phone_number = ''
      model.validate(:no_context)
    end

    it 'returns invalid' do
      expect(model.valid?(:no_context)).to be false
    end
  end

  context 'when invalid' do
    let(:invalid_telephone_numbers) do
      [
        '12 3 4 cat',
        '12dog34'
      ]
    end

    it 'returns invalid' do
      invalid_telephone_numbers.each do |number|
        model.phone_number = number
        expect(model.valid?(:no_context)).to(be(false), "Expected phone number #{number} to be invalid")
      end
    end
  end

  context 'when valid' do
    let(:valid_telephone_numbers) do
      [
        '+447123 123 123',
        '+407123 123 123',
        '+1 7123 123 123',
        '+447123123123',
        '07123123123',
        '01234 123 123 --()+ ',
        '01234 123 123 ext 123',
        '01234 123 123 x123',
        '(01234) 123123',
        '(12345) 123123',
        '(+44) (0)1234 123456',
        '+44 (0) 123 4567 123',
        '123 1234 1234 ext 123',
        '12345 123456 ext 123',
        '12345 123456 ext. 123',
        '12345 123456 ext123',
        '01234123456 ext 123',
        '123 1234 1234 x123',
        '12345 123456 x123',
        '12345123456 x123',
        '(1234) 123 1234',
        '1234 123 1234 x123',
        '1234 123 1234 ext 1234',
        '1234 123 1234  ext 123',
        '+44(0)123 12 12345'
      ]
    end

    it 'returns valid' do
      valid_telephone_numbers.each do |number|
        model.phone_number = number
        expect(model.valid?(:no_context)).to(be(true), "Expected phone number #{number} to be valid")
      end
    end
  end

  context 'when over 15 numbers' do
    before do
      model.phone_number = '123456791123456789'
      model.validate(:no_context)
    end

    it 'returns invalid' do
      expect(model.valid?(:no_context)).to be false
    end
  end

  context 'when 7 numbers or less' do
    before do
      model.phone_number = '1234567'
      model.validate(:no_context)
    end

    it 'returns invalid' do
      expect(model.valid?(:no_context)).to be false
    end
  end
end
