class SetProviderNameSearchOnProvider < ActiveRecord::Migration[6.0]
  def up
    say_with_time "Adding normalised version of provider_name to provider_name_search" do
      # Remove any non-alphanumeric characters and convert the provider_name to lower case
      # before storing it in provider_name_search
      execute <<-SQL
        UPDATE provider SET provider_name_search = regexp_replace(LOWER(provider_name), '[^0-9a-z]+', '' , 'g');
        COMMIT;
      SQL
    end
  end
end
