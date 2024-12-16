
require 'rest-client'
require 'json'
require 'cgi'

module Quasi
  class API
    @api_version = 'api/v1'
    class << self
      attr_accessor :base_url
  
      def get_uri(call) 
        #puts "#{@base_url}/#{@api_version}/#{call}"
        "#{@base_url}/#{@api_version}/#{call}"
      end

      def login(username, password, &block)
        resp = RestClient.post(get_uri("auth/login"), 
          {username: username, password: password}.to_json, 
          {content_type: :json, accept: :json} )
        block.call(resp)
      end
      def logout(refresh_token)
        resp = RestClient.get(get_uri("auth/logout"), 
          {cookies: {refreshToken: refresh_token}, content_type: :json, accept: :json} )
        yield resp if block_given?
      end
      def refresh_token(token, &block)
        resp = RestClient.get(get_uri("auth/refresh-token"), 
          {cookies: {refreshToken: token}, content_type: :json, accept: :json} )
        block.call(resp)
      end
  
      def robots(access_token, &block)
        resp = RestClient.get(get_uri("robots"), 
          {Authorization: "Bearer #{access_token}", accept: :json} )
        block.call(resp)
      end
      def robot_info(robot_id, access_token, &block)
        resp = RestClient.get(get_uri("robots/#{robot_id}/info"), 
          {Authorization: "Bearer #{access_token}", accept: :json} )
        block.call(resp)
      end
      def find_robot(serial_number, access_token, &block)
        filter = CGI.escape("{\"serialNumber\":\"#{serial_number}\"}") 
        resp = RestClient.get(get_uri("robots?filter=#{filter}"),  
          {Authorization: "Bearer #{access_token}", accept: :json} )
        block.call(resp)
      end
      def navigate_robot_to(robot_id, waypoint, access_token)
        resp = RestClient.post(get_uri("robots/#{robot_id}/navigate/#{waypoint}"), 
          {}.to_json,
          {Authorization: "Bearer #{access_token}", accept: :json} )
        yield(resp) if block_given?
      end
      def start_robot_route(robot_id, route, access_token)
        resp = RestClient.post(get_uri("robots/#{robot_id}/startRoute/#{route}"), 
          {}.to_json,
          {Authorization: "Bearer #{access_token}", accept: :json} )
        yield(resp) if block_given?
      end
    end
  end
end
