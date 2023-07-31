# frozen_string_literal: true

module User
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # You should configure your model like this:
    # devise :omniauthable, omniauth_providers: [:twitter]

    # You should also create an action method in this controller like this:
    def twitter; end

    # More info at:
    # https://github.com/heartcombo/devise#omniauth

    # GET|POST /resource/auth/twitter

    # GET|POST /users/auth/twitter/callback

    # The path used when OmniAuth fails
  end
end
