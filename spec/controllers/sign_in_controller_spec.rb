# frozen_string_literal: true

require 'rails_helper'

describe SignInController do
  describe '#index' do
    render_views

    it 'renders the index page' do
      get :index

      expect(response.body).to have_content 'Sign in to Publish teacher training courses'
    end
  end
end
