class PagesController < ApplicationController
  before_filter :check_locale, :set_locale
  layout 'pages'

  def about
    @bg_colour = "white"
    @background = "matted"
    @active = "about"
  end

  def help
    @bg_colour = "white"
    @background = "matted"
    @active = "help"
  end

  def home
    @bg_colour = "grey"
    @background = ""
    @active = "home"
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def check_locale
    unless ["ar", "en"].include?(params[:locale])
      redirect_to locale: "en"
    end
  end

  def default_url_options(options={})
    { :locale => I18n.locale }
  end
end
