require 'httparty'
require 'json'

class Kele
include HTTParty
include JSON

  def initialize(email, password)
    response = self.class.post(base_api_url("sessions"), body: { email: email, password: password })
    raise "Invalid email or password" if response.code == 404
    @auth_token = response["auth_token"]
  end

  def get_me
    response = self.class.get(base_api_url("users/me"), headers: { authorization: @auth_token })
    @user = JSON.parse(response.body)
  end

  private
  def base_api_url(endpoint)
    "https://www.bloc.io/api/v1/#{endpoint}"
  end

end
