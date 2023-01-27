# frozen_string_literal: true

require 'rails_helper'

describe SubjectArea do
  it 'excludes the discontinued subject area' do
    expect(described_class.active.find_by(typename: 'DiscontinuedSubject')).to be_nil
  end
end
