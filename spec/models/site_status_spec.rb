# == Schema Information
#
# Table name: course_site
#
#  id                         :integer          not null, primary key
#  applications_accepted_from :date
#  course_id                  :integer
#  publish                    :text
#  site_id                    :integer
#  status                     :text
#  vac_status                 :text
#
require 'rails_helper'


RSpec.describe SiteStatus, type: :model do
  describe 'associations' do
    it { should belong_to(:site) }
    it { should belong_to(:course) }
  end
end
