RSpec.shared_context 'when authenticated' do
  before do
    page.driver.browser.authorize("bat", "beta")
  end
end
