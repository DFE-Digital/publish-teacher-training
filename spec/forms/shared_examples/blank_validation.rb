# frozen_string_literal: true

shared_examples 'blank validation' do |attribute, message|
  it { is_expected.to validate_presence_of(attribute).with_message(message) }
end
