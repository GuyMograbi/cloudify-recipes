#!/usr/bin/env ruby

require 'rubygems'
require 'rest_client'
require 'json'
require 'yaml'
require 'erb'
require 'uri'
require 'net/ftp'
require 'net/http'
require 'net/https' if RUBY_VERSION < '1.9'

DEFAULT_CONFIGURATION_YML = '/etc/imcloud/imcloud_client.yml'

module IMCloudClient
  class << self
    attr_writer :configuration

    def configuration
       @configuration ||= Configuration.new
    end

    #########################
    # Product downloads API #
    #########################

    # Returns a hash containing URL and protocol for a given product/cloud/geography
    def url(product_name, args = {})
      configure if @configuration.nil?

      product_name = ERB::Util.url_encode(product_name)
      format = args[:format] || "json"
      response = RestClient.get("#{configuration.download_url}/#{product_name}.#{format}",
                                :params => args.merge(:api_key => configuration.api_key))
      format.to_s == "json" ? JSON.parse(response.to_str) : response.to_str
    end

    # Downloads the file for a given product to a chosen local_path directory location
    def download(local_path, product_name, args = {})
      hash = url(product_name, args)

      protocol = hash['protocol']
      uri = URI(hash['url'])

      hostname = uri.host
      filename = File.basename(uri.path)

      if protocol =~ /http/
        uri = URI.parse(hash['url'])
        http = Net::HTTP.new(uri.host, uri.port)
        
        begin
          file = open("#{local_path}/#{filename}", "wb")
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
          request = Net::HTTP::Get.new(uri.request_uri)

          http.request(request) do |response|
            response.read_body do |segment|
              file.write(segment)
            end
          end
        
        ensure
          file.close
        end
      elsif protocol =~ /ftp/
        ftp_user = uri.user
        ftp_password = uri.password

        Net::FTP.open(hostname) do |ftp|
          begin
            if ftp_user && ftp_password
              ftp.login(ftp_user, ftp_password)
            else
              ftp.login
            end
            ftp.getbinaryfile(uri.path, "#{local_path}/#{filename}")
          rescue
            # Return code needed by scripts calling this method
            return -1
          end
        end
      end

      # Success
      return "#{local_path}/#{filename}"
    end

    # Dynamically generates methods such as
    # aws_us_east_1 and aws_ap_northeast_1 on the fly.
    def method_missing(m, *args, &block)
      path = args.shift
      product = args.shift
      format = args.shift
      tokens = m.to_s.split("_")

      cloud = tokens.shift
      geography = tokens.join("-")

      if format
        download(path, product, {:cloud => cloud, :geography => geography, :format => format})
      else
        download(path, product, {:cloud => cloud, :geography => geography})
      end
    end
  end

  def self.configure(config_file = nil)
    self.configuration ||= Configuration.new

    if config_file
      if File.exists?(config_file)
        config = YAML::load_file(config_file)
        configuration.api_key = config["api_key"]
        configuration.api_url = config["api_url"]
      else
        # The specified file doesn't exist
        raise Errno::ENOENT
      end
    elsif !block_given?
      configure(DEFAULT_CONFIGURATION_YML) if File.exists?(DEFAULT_CONFIGURATION_YML)
    end

    if block_given?
      # Handles the block format
      yield(configuration)
    end

    configuration.api_key ||= ENV['IMCLOUD_API_KEY'] if ENV['IMCLOUD_API_KEY']
    configuration.api_url ||= ENV['IMCLOUD_API_URL'] || "https://my.imdemocloud.com/api"
    configuration.download_url = "#{configuration.api_url}/products/search"
    configuration
  end

  class Configuration
    attr_accessor :download_url, :api_url, :api_key
  end
end