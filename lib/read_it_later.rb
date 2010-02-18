# The ReadItLater class is a Ruby implementation
# of the API provided by readitlaterlist.com
# It's pretty much a one-to-one method-by-method
# implementation in ruby.

# Author::    Gabriel Medina  (mailto:rha7.com@gmail.com)
# Copyright:: Copyright (c) 2010 Gabriel Medina
# License::   LGPL

require 'open-uri'
require 'json'

# This is the main class for the ReadItLater library,
# it allows you to interact with the service.
class ReadItLater
  
  # For responses status code indicating success.
  STATUS_SUCCESS     = 200

  # For responses status code indicating invalid request (wrong arguments).
  STATUS_INVALID     = 400

  # For responses status code indicating denied access (usually, login/pass wrong).
  STATUS_DENIED      = 401

  # For responses status code indicating access rate exceeded, wait a few minutes before trying again,
  # or issue a 'stat' or 'api' method calls to see more details.
  STATUS_EXCEEDED    = 403

  # For responses status code indicating the service is down for maintenance.
  STATUS_MAINTENANCE = 503
  
  # The readitlaterlist.com base URL for requests via http.
  URL_BASE = 'https://readitlaterlist.com/v2'
  
  # The specific URLs for methods, with http base URL_BASE
  URLS = {
    :add    => ReadItLater::URL_BASE+'/add'   ,
    :send   => ReadItLater::URL_BASE+'/send'  ,
    :stats  => ReadItLater::URL_BASE+'/stats' ,
    :get    => ReadItLater::URL_BASE+'/get'   ,
    :auth   => ReadItLater::URL_BASE+'/auth'  ,
    :signup => ReadItLater::URL_BASE+'/signup',
    :api    => ReadItLater::URL_BASE+'/api'   
  }

  # Holds the response to the last request/method call.
  attr_reader :last_response
  
  # Inner class to ReadItLater to hold user details
  class User
    
    # User name for User object
    attr_accessor :username
    
    # Password for User object
    attr_accessor :password
    
    # Create a new ReadItLater::User object, to be used in subsequent calls.
    #
    # @param [String] username The user name for this instance
    # @param [String] password The password for this instance
    def initialize(username=nil, password=nil)
      @username, @password, @last_response = username, password, ""
    end
  end
  
  # Holds the api_key assigned to this ReadItLater instance
  attr_accessor :api_key
  
  # Create a new ReadItLater instance
  #
  # @param [String] api_key Must be the API key generated from the readitlaterlist.com
  def initialize(api_key)
    @api_key = api_key
  end
  
  # Add a new URL to a User bookmarks list
  #
  # @param [ReadItLater::User] user The ReadItLater::User instance representing the user
  # @param [String] url The URL string to be added to the bookmark list
  def add(user, url)
    @last_response = query(:add, user, :url => url)
  end
  
  # Send several changes to readitlaterlist.com
  # The params hash is built as described in http://readitlaterlist.com/api/docs/#send, but in ruby a Ruby Hash.
  # Example:
  #
  #<pre><code>
  # params = {
  #    :new => [
  #      { :url => "http://www.url1.com/", :title => "URL New 1" },
  #      { :url => "http://www.url2.com/", :title => "URL New 2" },
  #      { :url => "http://www.url3.com/", :title => "URL New 3" }
  #    ],
  #    :read => [
  #        { :url => "http://www.url1.com/" },
  #        { :url => "http://www.url2.com/" },
  #        { :url => "http://www.url3.com/" }
  #    ],
  #    :update_title => [
  #      { :url => "http://www.url1.com/", :title => "Updated URL New 1" },
  #      { :url => "http://www.url2.com/", :title => "Updated URL New 2" },
  #      { :url => "http://www.url3.com/", :title => "Updated URL New 3" }
  #    ],
  #    :update_tags => [
  #      { :url => "http://www.url1.com/", :tags => "url1tag1, url1tag2, url1tag3" },
  #      { :url => "http://www.url2.com/", :tags => "url2tag1, url2tag2, url2tag3" },
  #      { :url => "http://www.url3.com/", :tags => "url3tag1, url3tag2, url3tag3" }
  #    ]
  # }
  # </code></pre>
  #
  # @param [ReadItLater::User] user The ReadItLater::User instance representing the user
  # @param [Hash] params The changes to be sent as described in http://readitlaterlist.com/api/docs/#send, in Ruby hash format
  def send(user, params)
    %w(new read update_title update_tags).map(&:to_sym).each do |param|
      params[param] = URI.escape((0..params[param].size-1).to_a.map{|n|{n.to_s=>params[param][n]}}.inject(){|a,b|a.merge(b)}.to_json) if params[param]
    end
    @last_response = query(:send, user, params)
  end
  
  def stats(user)
    response = query(:stats, user, :format => "json")
    response[:data] = stringify_keys(JSON.parse(response[:text]))
    response[:data][:user_since] = Time.at(response[:data][:user_since].to_i) 
    @last_response = response
  end
  
  def get(user, call_params)
    params = { :format => "json" }
    params[:state] = call_params[:state].to_s.strip if call_params[:state]
    params[:myAppOnly] = (call_params[:mine_only] ? "1" : "0") if call_params[:mine_only]
    params[:since] = call_params[:since].to_i if call_params[:since]
    params[:count] = call_params[:count] if call_params[:count]
    params[:page] = call_params[:page] if call_params[:page]
    params[:tags] = (call_params[:tags] ? "1" : "0") if call_params[:tags]
    response = query(:get, user, params)
    response[:data] = stringify_keys(JSON.parse(response[:text]))
    response[:data][:since] = Time.at(response[:data][:since])
    response[:data][:status] = response[:data][:status] == 1 ? :normal : :no_changes 
    response[:data][:list] = response[:data][:list].map{|k,v|v.merge(:time_added => Time.at(v[:time_added].to_i), :time_updated => Time.at(v[:time_updated].to_i), :item_id => v[:item_id].to_i, :read => (v[:state].strip == "0")).delete_if{|k,v|k==:state}} 
    @last_response = response
  end
  
  def auth(user)
    @last_reponse = query(:auth, user)
  end
  
  def signup(user)
    @last_reponse = query(:signup, user)
  end
  
  def api
    @last_response = query(:api, User.new('',''))
  end
  
  private
  
  def ril_api_url(method, user, params={})
    params = { :apikey => @api_key, :username => user.username, :password => user.password }.merge(params)
    query_str = URLS[method] + "?" + params.map{|k,v| "#{k.to_s}=#{URI.escape(v.to_s)}" }.join("&")
    return query_str
  end
  
  def unique_id
    return (1..24).to_a.map{|i|(('a'..'z').to_a+('0'..'9').to_a)[rand(36)]}.join
  end

  def query(method, user, params={})
    response = nil
    begin
      open(ril_api_url(method, user, params)) do |f|
        response = build_response(f)
      end
    rescue OpenURI::HTTPError => e
      response = build_response(e.io)
    end
    return response
  end
  
  def build_response(io_object)
    return {
      :text => io_object.read.strip,
      :status => io_object.meta["status"].split[0].strip.to_i,
      :user => {
        :limit     => (io_object.meta["x-limit-user-limit"    ] || "-1").to_i,
        :remaining => (io_object.meta["x-limit-user-remaining"] || "-1").to_i,
        :reset     => (io_object.meta["x-limit-user-reset"    ] || "-1").to_i
      },
      :key => {
        :limit     => (io_object.meta["x-limit-key-limit"     ] || "-1").to_i,
        :remaining => (io_object.meta["x-limit-key-remaining" ] || "-1").to_i,
        :reset     => (io_object.meta["x-limit-key-reset"     ] || "-1").to_i
      },
      :error => io_object.meta["x-error"]
    }    
  end
  
  def stringify_keys(hsh)
    hsh.map{|k,v|{k.to_sym => (v.class == Hash ? stringify_keys(v) : v)}}.inject(){|a,b|a.merge(b)}
  end
  
end


