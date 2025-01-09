
require_relative 'api'
require_relative 'user'

class Cart

  attr_reader :id, :serial_number, :waypoints, :routes, :online, :navigation_feedback

  def self.list(user)
    Quasi::API.robots(user.access_token) do |resp|
      body = JSON.parse(resp.body)
      body['robots'].select{|r| r['modelType'] == 'cart'}.map { |r| {id: r['_id'], name: r['name'], sn: r['serialNumber'], model: r['modelName'], online: r['online']}} 
    end
  end

  def self.find_by_sn(user, serial_number)
    Quasi::API.find_robot(serial_number, user.access_token) do |resp| 
      #puts resp
      body = JSON.parse(resp.body)
      robots = body["robots"]
      robot = robots.select() { |r| r['serialNumber'] == serial_number }
      throw "Cart not found" unless robot.size == 1
      find_by_id(user, robot[0]['_id'])
    end
  end

  def self.find_by_id(user, robot_id)
    Quasi::API.robot_info(robot_id, user.access_token) do |resp|
      body = JSON.parse(resp.body)
      Cart.new(user, body)
    end
  end

  def update_status
    Quasi::API.robot_info(id, @user.access_token) do |resp|
      body = JSON.parse(resp.body)
      set_values(body)
    end
  end

  def navigate_to(waypoint)
    Quasi::API.navigate_robot_to(id, waypoint, @user.access_token)
  end

  def start_route(route)
    Quasi::API.start_robot_route(id, route, @user.access_token)
  end

  def initialize(user, params)
    @user = user
    set_values(params)
  end

  def set_values(params)
    @id = params["_id"]
    @serial_number = params["serialNumber"]
    @waypoints = params["waypoints"]
    @routes = params["routes"]
    @online = params["connectedNow"]
    @navigation_feedback = params['status']['navigationFeedback']
  end

end
