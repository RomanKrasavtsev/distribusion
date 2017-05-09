#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'zip'

class Matrix
  START_URL = "http://challenge.distribusion.com/the_one"
  ROUTES_URL = "http://challenge.distribusion.com/the_one/routes"

  def initialize
    red_pill = take_a_red_pill
    @passphrase = red_pill["passphrase"]
    @location = red_pill["location"]
    @source_type = "sentinels"

    sentinels_routes = routes
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

  def routes
    uri = URI(ROUTES_URL)
    uri.query = URI.encode_www_form({
      passphrase: @passphrase,
      source: @source_type
    })

    response = Net::HTTP.get_response(uri)

    if response.content_type == 'application/zip'
      files = unzip_responce(response)
      files[0][:content] if files.count == 1
    end
  end

  def unzip_responce(response)
    file_name = response["content-disposition"].gsub(/attachment; filename\*=UTF-8''/, '') + ".zip"
    file = File.open(file_name, "w")
    file.write(response.body)
    file.close

    content = []
    Zip::File.open(file.path) do |zip_file|
      zip_file.each do |entry|
        if entry.ftype == :file && entry.name != "__MACOSX/sentinels/._routes.csv"
          item = {}
          item[:file] = entry.name
          item[:content] = entry.get_input_stream.read
          content << item
        end
      end
    end

    File.delete(file.path)
    content
  end
end

Matrix.new
