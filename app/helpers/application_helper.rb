module ApplicationHelper
  include Pagy::Frontend
  
  def header_items(current_user)
    return unless current_user

    items = [{ name: t("header.items.sign_out"), url: sign_out_path }]
    items
  end
end
