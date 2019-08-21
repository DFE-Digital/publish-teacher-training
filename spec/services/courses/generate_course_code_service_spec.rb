require 'rails_helper'

RSpec.describe Courses::GenerateCourseCodeService do
  let(:service) { described_class.new }

  it 'returns a course code like A000' do
    expect(service.execute).to match(/^[A-Z]\d{3}$/)
  end

  it 'does not include O' do
    expect(service.send(:valid_letters)).to_not include('O')
  end

  it 'does not include I' do
    expect(service.send(:valid_letters)).to_not include('I')
  end

  it 'does not include lower case letters' do
    letters_string = service.send(:valid_letters).join(' ')

    expect(letters_string).to_not match(/[a-z]/)
  end

  it 'does not include I' do
    expect(service.send(:valid_number)).to match(/^\d{1}$/)
  end

  it 'calls "valid_number three times' do
    expect(service).to receive(:valid_number).exactly(3).times.and_return('1', '1', '1')

    service.execute
  end
end
