# frozen_string_literal: true

require "rubygems"
require "bundler"
require "sinatra"
require "omniauth"
require "faraday"
require "logger"
require "byebug"

require "sb-omniauth-kakao"
# require_relative "../lib/sb-omniauth-kakao.rb"
# require "./lib/sb-omniauth-kakao"

require "dotenv"
Dotenv.load

# Do not use for production code.
# This is only to make setup easier when running through the sample.
#
# If you do have issues with certs in production code, this could help:
# http://railsapps.github.io/openssl-certificate-verify-failed.html
# OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class App < Sinatra::Base
  configure do
    set :sessions, true
    set :inline_templates, true

    # STDOUT의 sync 활성화로 버퍼링 방지
    STDOUT.sync = true

    # 로깅 설정
    $logger = Logger.new(STDOUT)
    $logger.level = Logger::DEBUG

    # Sinatra 로깅 활성화
    enable :logging
    set :logger, $logger
  end

  before do
    env["rack.logger"] = $logger
  end

  use Rack::Session::Cookie, secret: ENV.fetch("RACK_COOKIE_SECRET", "a3f5e6d7c8b9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5")

  # OAuth2 클라이언트의 로거를 Sinatra의 로거로 설정
  OAuth2::Client.class_eval do
    define_method(:logger) { $logger }
  end
  OmniAuth.config.logger = $logger
  use OmniAuth::Builder do
    # provider :kakao, ENV.fetch("KAKAO_CLIENT_ID", nil), ENV.fetch("KAKAO_CLIENT_SECRET", nil), access_type: "offline", prompt: "consent", provider_ignores_state: true, scope: "account_email,profile", :strategy_class => OmniAuth::Strategies::KakaoOauth2
    # provider :kakao, ENV.fetch("KAKAO_CLIENT_ID", nil), ENV.fetch("KAKAO_CLIENT_SECRET", nil),
    #          scope: ENV.fetch("KAKAO_CLIENT_SCOPE", "profile"),
    #          client_options: {
    #            connection_build: lambda do |builder|
    #              builder.request :url_encoded
    #              builder.response :logger, $logger
    #              builder.adapter Faraday.default_adapter
    #            end
    #          }
    provider :kakao, ENV.fetch("KAKAO_CLIENT_ID", nil), ENV.fetch("KAKAO_CLIENT_SECRET", nil),
             scope: ENV.fetch("KAKAO_CLIENT_SCOPE", "profile") do |builder|
      builder.client_options.connection_build do |conn|
        conn.request :url_encoded
        conn.response :logger, $logger, { headers: true, bodies: { request: false, response: true }, errors: true }
        conn.adapter Faraday.default_adapter
      end
      # connection_build

      # provider :kakao, "bcf75d0d9b0781ac4305d8750972ce25", "W7oQ3tX4Z9wj9gPJRqFlJ2waVVLTLfY8",
      #  scope: "profile,account_email" do |builder|
      # builder.request :url_encoded
      # # builder.response :logger, $logger, bodies: true
      # builder.response :logger, $logger, { headers: true, bodies: { request: false, response: true }, errors: true }
      # builder.adapter Faraday.default_adapter
    end
    # before_request_phase do |env|
    #   puts "before_request_phase >>>>>>>>>>"
    #   puts env["rack.session"]
    #   puts env["rack.session"]["user_params"]
    #   puts env["rack.request.form_hash"]["user"]
    #   request_env = env['omniauth.auth']
    #   print request_env
    #   puts "before_request_phase <<<<<<<<<<"
    # end
    # before_callback_phase do |env|
    #   puts "before_callback_phase >>>>>>>>>>"
    #   request_env = env['omniauth.auth']
    #   puts "=== OmniAuth Request ==="
    #   puts request_env.to_hash if request_env
    #
    #   # puts env["rack.session"]
    #   # puts env["rack.session"]["user_params"]
    #   # puts env["rack.request.form_hash"]["user"]
    #   puts "before_callback_phase <<<<<<<<<<"
    # end
    puts "OmniAuth::Strategies::KakaoOauth2"
    puts "KAKAO_CLIENT_ID: #{ENV.fetch("KAKAO_CLIENT_ID", nil)}"
    puts "KAKAO_CLIENT_SECRET: #{ENV.fetch("KAKAO_CLIENT_SECRET", nil)}"
    # on_failure do |env|
    #   error = env["omniauth.error"]
    #   puts "OmniAuth error: #{error.inspect}"
    #   OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    # end
  end

  get "/" do
    logger.info "========================================================"
    logger.debug "========================================================"
    logger.info "route GET /"
    <<-HTML
    <!DOCTYPE html>
    <html>
      <head>
        <title>Kakao OAuth2 Example</title>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
        <script>
          jQuery(function() {
            return $.ajax({
              url: 'https://apis.google.com/js/client:plus.js?onload=gpAsyncInit',
              dataType: 'script',
              cache: true
            });
          });

          window.gpAsyncInit = function() {
            gapi.auth.authorize({
              immediate: true,
              response_type: 'code',
              cookie_policy: 'single_host_origin',
              client_id: "#{ENV.fetch("KAKAO_CLIENT_ID", nil)}",
              scope: 'account_email profile'
            }, function(response) {
              return;
            });
            $('.kakao-login').click(function(e) {
              e.preventDefault();
              gapi.auth.authorize({
                immediate: false,
                response_type: 'code',
                cookie_policy: 'single_host_origin',
                client_id: "#{ENV.fetch("KAKAO_CLIENT_ID", nil)}",
                # scope: 'account_email profile'
                scope: 'profile'
              }, function(response) {
                if (response && !response.error) {
                  // kakao authentication succeed, now post data to server.
                  jQuery.ajax({type: 'POST', url: "/auth/kakao/callback", data: response,
                    success: function(data) {
                      // Log the data returning from kakao.
                      console.log(data)
                    }
                  });
                } else {
                  // kakao authentication failed.
                  console.log("FAILED")
                }
              });
            });
          };
        </script>
      </head>
      <body>
      <ul>
        <li>
          <form method='post' action='/auth/kakao'>
            <input type="hidden" name="authenticity_token" value="#{request.env["rack.session"]["csrf"]}">
            <button type='submit'>Login with Kakao</button>
          </form>
        </li>
        <li><a href='#' class="kakao-login">Sign in with Kakao via AJAX</a></li>
      </ul>
      </body>
    </html>
    HTML
  end

  helpers do
    def render_callback_page(auth, url)
      <<-HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>OmniAuth Callback - #{url}</title>
          <style>
              body {
                  font-family: Arial, sans-serif;
                  margin: 0;
                  padding: 0;
                  background-color: #f9f9f9;
                  color: #333;
              }
              header {
                  background-color: #4CAF50;
                  color: white;
                  padding: 1rem;
                  text-align: center;
              }
              .container {
                  max-width: 800px;
                  margin: 2rem auto;
                  padding: 1rem;
                  background: white;
                  border-radius: 8px;
                  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
              }
              h1 {
                  font-size: 1.5rem;
                  margin-bottom: 1rem;
              }
              pre {
                  background: #f4f4f4;
                  padding: 1rem;
                  border-radius: 8px;
                  overflow-x: auto;
                  font-size: 0.9rem;
              }
          </style>
      </head>
      <body>
          <header>
              <h1>OmniAuth Callback - #{url}</h1>
          </header>
          <div class="container">
              <h1>#{params[:provider].capitalize} Callback Success</h1>
              <p>The callback from <strong>#{params[:provider].capitalize}</strong> was successful. Below is the data received:</p>
              <pre>#{JSON.pretty_generate(auth)}</pre>
          </div>
      </body>
      </html>
      HTML
    end
  end

  post "/auth/:provider/callback" do
    logger.info "========================================================"
    logger.info "route POST /auth/:provider/callback"
    # content_type "text/plain"
    begin
      logger.info "begin"
      auth = request.env["omniauth.auth"]
      logger.info auth
      logger.info auth.to_hash
      # request.env["omniauth.auth"].to_hash.inspect

      render_callback_page(auth, request.url)
    rescue StandardError
      "No Data"
    end
  end

  get "/auth/:provider/callback" do
    logger.info "========================================================"
    logger.info "route GET /auth/:provider/callback"
    # content_type "text/plain"
    begin
      logger.info "begin"
      auth = request.env["omniauth.auth"]
      logger.info auth
      logger.info auth.to_hash
      # request.env["omniauth.auth"].to_hash.inspect

      render_callback_page(auth, request.url)
    rescue StandardError
      "No Data"
    end
  end

  get "/auth/failure" do
    logger.info "========================================================"
    logger.info "route GET /auth/failure"
    begin
      logger.info "begin"
      logger.info request.env["omniauth.auth"]
      logger.info request.env["omniauth.auth"].to_hash
      request.env["omniauth.auth"].to_hash.inspect
    rescue StandardError
      <<-HTML
      <!DOCTYPE html>
      <html>
        <head>
          <title>Kakao OAuth2 Example</title>
        </head>
        <body>
          <h1>No Data</h1>
          <p>Request Params: #{request.params.inspect}</p>
        </body>
      </html>
      HTML
    end
  end
end

use Rack::CommonLogger, $logger
run App.new
