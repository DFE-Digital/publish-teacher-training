class MagicLinksController < ApplicationController
  layout "application"

  skip_before_action :authenticate

  def new
    @magic_link_form = Publish::Authentication::MagicLinkForm.new
  end

  def create
    @magic_link_form = Publish::Authentication::MagicLinkForm.new(email: magic_link_params[:email])

    if @magic_link_form.submit
      redirect_to magic_link_sent_path
    else
      render :new
    end
  end

  def magic_link_sent; end

private

  def magic_link_params
    params.require(:publish_authentication_magic_link_form).permit(:email)
  end
end
