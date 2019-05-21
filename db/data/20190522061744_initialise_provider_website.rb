class InitialiseProviderWebsite < ActiveRecord::Migration[5.2]
  def change
    # Initialize website with the same data as url
    Provider.update_all("website = url")
  end
end
