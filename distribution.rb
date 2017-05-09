#!/usr/bin/env ruby

require 'net/http'
require 'json'

class Matrix
  START_URL = "http://challenge.distribusion.com/the_one"

  def initialize
    red_pill = take_a_red_pill
  end

  private

  def take_a_red_pill
    uri = URI(START_URL)
    http_request = Net::HTTP::Get.new(uri)
    http_request["Accept"] = "application/json"

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(http_request)
    end

    if response.content_type == 'application/json'
      JSON.parse(response.body.force_encoding('UTF-8'))["pills"]["red"]
    end
  end
end

Matrix.new
