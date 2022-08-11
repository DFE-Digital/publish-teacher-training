namespace :find, path: "/find" do
  get "/", to: "application#index"
  get "/accessibility", to: "pages#accessibility", as: :accessibility
end
