require 'httparty'
require 'json'
require './lib/roadmap.rb'

class Kele
include HTTParty
include JSON
include Roadmap

  def initialize(email, password)
    response = self.class.post(base_api_url("sessions"), body: { email: email, password: password })
    raise "Invalid email or password" if response.code == 404
    @auth_token = response["auth_token"]
  end

  def get_me
    response = self.class.get(base_api_url("users/me"), headers: { authorization: @auth_token })
    @user = JSON.parse(response.body)
  end

  def get_mentor_availability(mentor_id)
    response = self.class.get(base_api_url("mentors/#{mentor_id}/student_availability"), headers: { authorization: @auth_token })
    @mentor_availability = JSON.parse(response.body)
    available = []
    @mentor_availability.each do |availability|
      if availability["booked"] == nil
        available << availability
      end
    end
    available
  end

  def get_messages(page = nil)
    if page != nil
      response = self.class.get(base_api_url("message_threads?page=#{page}"), headers: { authorization: @auth_token })
    else
      response = self.class.get(base_api_url("message_threads"), headers: { authorization: @auth_token })
    end
    @messages = JSON.parse(response.body)
  end

  def create_message(sender, recipient_id, token=nil, subject, message)
    response = self.class.post(base_api_url("messages"),
    body: {
      "sender": sender,
      "recipient_id": recipient_id,
      "token": token,
      "subject": subject,
      "stripped-text": message
    },
    headers: { authorization: @auth_token })
    response
  end

  def get_remaining_checkpoints(chain_id)
    response = self.class.get(base_api_url("enrollment_chains/#{chain_id}/checkpoints_remaining_in_section"), headers: { authorization: @auth_token })
    @remaining_checkpoints = JSON.parse(response.body)
  end

  private
  def base_api_url(endpoint)
    "https://www.bloc.io/api/v1/#{endpoint}"
  end

end
