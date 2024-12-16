require 'json'
require 'jwt'
require 'async'

require_relative 'api'

module Quasi
  class User 
    attr_reader :fullname, :access_token  
  
    def self.authenticate(username, password)
      Quasi::API.login(username, password) do |resp|
        body = JSON.parse(resp.body)
        u = new
        u.set_values(body['user'])
        u.procesTokens(body["accessToken"], resp.cookies["refreshToken"])
        u
      end
    end
  
    def procesTokens(a_token, r_token)
      @access_token = a_token
      @refresh_token = r_token
      jwt_data = JWT.decode(@access_token, nil, false)
      sleep_duration = jwt_data[0]["exp"] - Time.now.to_i - 5
      @task = Async do
        sleep sleep_duration
        Quasi::API.refresh_token(@refresh_token) do |resp|
          body = JSON.parse(resp.body)
          set_values(body['user'])
          procesTokens(body["accessToken"], resp.cookies["refreshToken"])        
        end
      end    
    end
    def set_values(params)
      #puts params
      @fullname = params["fullname"]
    end

    def logout
      @task.stop() if @task
      Quasi::API.logout(@refresh_token)
    end
  end
end