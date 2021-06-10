module ApplicationHelper
  def header_items(current_user)
    return unless current_user

    [{ name: t("header.items.sign_out"), url: sign_out_path }]
  end
end
