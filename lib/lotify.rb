# frozen_string_literal: true

require "lotify/version"
require "net/http"
require "JSON"

module Lotify
  class Error < StandardError; end

  class Client
    attr_accessor :client_id
    attr_accessor :client_secret
    attr_accessor :redirect_uri
    attr_accessor :bot_origin
    attr_accessor :api_origin

    def initialize(options = {})
      self.client_id = options[:client_id]
      self.client_secret = options[:client_secret]
      self.redirect_uri = options[:redirect_uri]

      self.bot_origin = options[:bot_origin] || "https://notify-bot.line.me"
      self.api_origin = options[:api_origin] || "https://notify-api.line.me"
    end

    # 發送一個get
    # option: :url, :header, :param, :ssl_verify
    def get(option)
      url = URI(option[:url])
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = option[:url]["https://"].nil? == false
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless option[:ssl_verify]
      request = Net::HTTP::Get.new(url)
      option[:header]&.each do |key, value|
        request[key] = value
      end
      http.request(request)
    end

    # 發送一個post
    # option: :url, :header, :param, :ssl_verify
    def post(option)
      url = URI(option[:url])
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = option[:url]["https://"].nil? == false
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless option[:ssl_verify]
      request = Net::HTTP::Post.new(url)
      option[:header]&.each do |key, value|
        request[key] = value
      end
      request.set_form_data(option[:param] || {})
      http.request(request)
    end

    # Get Auth Link
    #
    # Get The OAuth2 authorization endpoint URI.
    #
    # @param state Assigns a token that can be used for responding to CSRF attacks
    #
    # CSRF attacks are typically countered by assigning a hash value generated from a user"s session ID, and then verifying the state parameter variable when it attempts to access redirect_uri.
    #
    # LINE Notify is designed with web applications in mind, and requires state parameter variables.
    # @returns The OAuth2 authorization endpoint URI
    def get_auth_link(state)
      data = {
        scope: "notify",
        response_type: "code",
        client_id: self.client_id,
        redirect_uri: self.redirect_uri,
        state: state
      };

      "#{self.bot_origin}oauth/authorize?#{URI.encode_www_form(data)}"
    end


    # Get Token
    #
    # The OAuth2 token endpoint.
    #
    # @param code Assigns a code parameter value generated during redirection
    # @returns An access token for authentication.
    def get_token(code)
      option = {
        url: "#{self.bot_origin}/oauth/token",
        header: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        param: {
          grant_type: "authorization_code",
          client_id: self.client_id,
          client_secret: self.client_secret,
          redirect_uri: self.redirect_uri,
          code: code
        }
      }
      response = post(option)
      json = JSON.parse(response.body)
      json["access_token"]
    end


    # Status
    #
    # An API for checking connection status. You can use this API to check the validity of an access token. Acquires the names of related users or groups if acquiring them is possible.
    #
    # On the connected service side, it"s used to see which groups are configured with a notification and which user the notifications will be sent to. There is no need to check the status with this API before calling /api/notify or /api/revoke.
    #
    # If this API receives a status code 401 when called, the access token will be deactivated on LINE Notify (disabled by the user in most cases). Connected services will also delete the connection information.
    #
    # ## Expected use cases
    # If a connected service wishes to check the connection status of a certain user
    #
    # As LINE Notify also provides the same feature, support for this API is optional.
    #
    # @param accessToken the accessToken you want to revoke
    # @returns
    # - status: Value according to HTTP status code.
    # - message: Message visible to end-user.
    # - targetType: If the notification target is a user: "USER". If the notification target is a group: "GROUP".
    # - target: If the notification target is a user, displays user name. If acquisition fails, displays "null". If the notification target is a group, displays group name. If the target user has already left the group, displays "null".
    def status(access_token)
      option = {
        url: "#{api_origin}/api/status",
        header: {
          Authorization: "Bearer #{access_token}",
        }
      }
      response = get(option)
      JSON.parse(response.body)
    end

    # Send
    #
    # Sends notifications to users or groups that are related to an access token.
    #
    # If this API receives a status code 401 when called, the access token will be deactivated on LINE Notify (disabled by the user in most cases). Connected services will also delete the connection information.
    #
    # Requests use POST method with application/x-www-form-urlencoded (Identical to the default HTML form transfer type).
    #
    # ## Expected use cases
    # When a connected service has an event that needs to send a notification to LINE
    #
    # @param accessToken An access token related to users or groups
    # @param message The notification content
    # @param options Other optional parameters
    # @returns
    # - status: Value according to HTTP status code
    # - message: Message visible to end-user
    def send(access_token, param)
      option = {
        url: "#{api_origin}/api/notify",
        header: {
          "Content-Type": "application/x-www-form-urlencoded",
          Authorization: "Bearer #{access_token}",
        },
        param: param
      }
      response = post(option)
      JSON.parse(response.body)
    end

    # Revoke
    #
    # An API used on the connected service side to revoke notification configurations. Using this API will revoke all used access tokens, disabling the access tokens from accessing the API.
    #
    # The revocation process on the connected service side is as follows
    #
    # 1. Call /api/revoke
    # 2. If step 1 returns status code 200, the request is accepted, revoking all access tokens and ending the process
    # 3. If step 1 returns status code 401, the access tokens have already been revoked and the connection will be d
    # 4. If step 1 returns any other status code, the process will end (you can try again at a later time)
    #
    # ### Expected use cases
    # When the connected service wishes to end a connection with a user
    #
    # As LINE Notify also provides the same feature, support for this API is optional.
    #
    # @param accessToken the accessToken you want to revoke
    # @returns
    # - status: Value according to HTTP status code
    # - message: Message visible to end-user
    def revoke(access_token)
      option = {
        url: "#{api_origin}/api/revoke",
        header: {
          "Content-Type": "application/x-www-form-urlencoded",
          Authorization: "Bearer #{access_token}",
        }
      }
      response = post(option)
      JSON.parse(response.body)
    end
  end
end
