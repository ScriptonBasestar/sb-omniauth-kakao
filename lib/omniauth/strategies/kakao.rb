# frozen_string_literal: true

require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Kakao < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = "account_email,profile".freeze

      BASE_URL = "https://kauth.kakao.com".freeze
      AUTHORIZE_URL = "/oauth/authorize".freeze
      AUTHORIZE_TOKEN_URL = "/oauth/token".freeze

      TOKEN_INFO_URL = "/oauth/tokeninfo".freeze

      OPENID_CONFIG_URL = "https://kauth.kakao.com/.well-known/openid-configuration".freeze

      # USER_INFO_URL = 'v1/oidc/userinfo'
      USER_INFO_URL = "https://kapi.kakao.com/v2/user/me".freeze

      option :client_options,
             site: BASE_URL,
             authorize_url: AUTHORIZE_URL,
             token_url: AUTHORIZE_TOKEN_URL

      uid {
        OmniAuth.logger.send :debug, "uid >>>>>>>>>>"
        raw_info["id"].to_s
      }

      info do
        OmniAuth.logger.send :debug, "info >>>>>>>>>>"
        hash = {
          name: raw_info["properties"]["nickname"],
          username: raw_info["kakao_account"]["email"],
          image: raw_info["properties"]["thumbnail_image"]
        }
        if raw_info["kakao_account"]["has_email"] && raw_info["kakao_account"]["is_email_verified"] && raw_info["kakao_account"]["is_email_valid"]
          hash[:email] = raw_info["kakao_account"]["email"]
        end
        hash
      end

      extra do
        OmniAuth.logger.send :debug, "extra >>>>>>>>>>"
        { raw_info: raw_info }
      end

      def callback_url
        options.redirect_url || (full_host + callback_path)
      end

      # def authorize_params
      #   options.authorize_params[:state] = SecureRandom.hex(24)
      #
      #   if OmniAuth.config.test_mode
      #     @env ||= {}
      #     @env["rack.session"] ||= {}
      #   end
      #
      #   params = options.authorize_params
      #                   .merge(options_for("authorize"))
      #                   .merge(pkce_authorize_params)
      #
      #   params[:client_id] = options.client_id  # client_id 추가
      #
      #   session["omniauth.pkce.verifier"] = options.pkce_verifier if options.pkce
      #   session["omniauth.state"] = params[:state]
      #
      #   params
      # end

      def auth_token_params
        verifier = session.delete("omniauth.pkce.verifier")
        params = {
          code: request.params["code"],
          client_id: options.client_id,
          client_secret: options.client_secret,
          redirect_uri: callback_url,
          grant_type: "authorization_code"
        }
        params[:code_verifier] = verifier if verifier
        params
      end

      def build_access_token
        verifier = request.params["code"]
        token = client.auth_code.get_token(verifier, {
          redirect_uri: callback_url,
          client_id: options.client_id,
          # client_secret: options.client_secret
        }.merge(token_params.to_hash(symbolize_keys: true)), deep_symbolize(options.auth_token_params))
        token
      end

      private

      def raw_info
        @raw_info ||= access_token.get(USER_INFO_URL).parsed
      end
    end
  end
end

OmniAuth.config.add_camelization "kakao", "Kakao"
