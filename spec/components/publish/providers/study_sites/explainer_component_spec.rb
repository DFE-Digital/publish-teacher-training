# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publish::Providers::StudySites::ExplainerComponent, type: :component do
  it 'renders Study Site information for the Provider' do
    render_inline(described_class.new)

    expect(page).to have_text('A study site, such as a university campus, is where trainees do theoretical training. Add study sites for your organisation and then attach one or more to a course from the ‘Basic details’ tab on the course page.')
    expect(page).to have_text('Candidates will see a list of the attached study sites in the ‘Training locations’ section on the course page on Find.')
  end
end
