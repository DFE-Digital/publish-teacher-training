describe "Seed" do
  it "seeds without error" do
    # https://stackoverflow.com/questions/38483820/testing-successful-seed-with-minitest-rspec
    load Rails.root.join("db/seeds.rb")
  end
end
