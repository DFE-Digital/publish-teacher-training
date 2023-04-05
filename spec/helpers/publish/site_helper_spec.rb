# frozen_string_literal: true

require 'rails_helper'

module Publish
  describe SiteHelper do
    describe '#site_has_no_course?' do
      let(:site) { create(:site) }

      context 'with no course' do
        it 'is true if no associcated course' do
          expect(site_has_no_course?(site)).to be true
        end
      end

      context 'with an associated course' do
        let(:course) { create(:course) }

        it 'is false with associcated course' do
          course.sites << site
          expect(site_has_no_course?(site)).to be false
        end
      end
    end
  end
end
