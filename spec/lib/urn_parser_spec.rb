# frozen_string_literal: true

require 'rails_helper'

RSpec.describe URNParser do
  subject { described_class.new(urns).call }

  let(:urns) do
    <<~URNS
      123456
        123345\r\n



      \t1234234
      1234324,, asdfasd,
    URNS
  end

  it 'parses all the URNs correctly' do
    expect(subject).to eq(%w[
                            123456
                            123345
                            1234234
                            1234324
                            asdfasd
                          ])
  end
end
