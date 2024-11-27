# frozen_string_literal: true

require 'rails_helper'

feature 'Canonical tags' do
  context 'when visiting Find pages', :with_find_constraint do
    scenario 'Find pages contain canonical tags' do
      visit '/'

      expect(page).to have_css("link[rel='canonical'][href='http://www.example.com/']", visible: :all)
      expect(page).to have_css("meta[property='og:url'][content='http://www.example.com/']", visible: :all)
    end
  end

  context 'when visiting Publish pages', :with_publish_constraint do
    scenario 'Publish pages contain canonical tags' do
      visit '/'

      expect(page).to have_css("link[rel='canonical'][href='http://www.example.com/sign-in/']", visible: :all)
      expect(page).to have_css("meta[property='og:url'][content='http://www.example.com/sign-in/']", visible: :all)
    end
  end
end
