# frozen_string_literal: true

require 'rails_helper'

describe SignInController do
  describe '#index' do
    it 'renders the index page' do
      get :index
      expect(response).to render_template('sign_in/index')
    end
  end
end
