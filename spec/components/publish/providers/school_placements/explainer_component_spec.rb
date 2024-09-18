# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publish::Providers::SchoolPlacements::ExplainerComponent, type: :component do
  it 'renders School Placement information for the Provider' do
    render_inline(described_class.new)

    expect(page).to have_text('Add the schools you can offer placements in. A placement school is where candidates will go to get classroom experience.', normalize_ws: true)
    expect(page).to have_text("Your courses will not appear in candidate's location searches if you do not add placement schools to them.", normalize_ws: true)
    expect(page).to have_link('Find out more about why you should add school placement locations', href: 'https://www.publish-teacher-training-courses.service.gov.uk/how-to-use-this-service/add-schools-and-study-sites')
    expect(page).to have_text('Add placement schools here, then attach them to any of your courses from the ‘Basic details’ tab on each course page.', normalize_ws: true)
  end
end
