require 'open-uri'
require 'json'

class ReadItLater
  
  STATUS_SUCCESS     = 200
  STATUS_INVALID     = 400
  STATUS_DENIED      = 401
  STATUS_EXCEEDED    = 403
  STATUS_MAINTENANCE = 503
  
  URL_BASE = 'https://readitlaterlist.com/v2'
  URLS = {
    :add    => ReadItLater::URL_BASE+'/add'   ,
    :send   => ReadItLater::URL_BASE+'/send'  ,
    :stats  => ReadItLater::URL_BASE+'/stats' ,
    :get    => ReadItLater::URL_BASE+'/get'   ,
    :auth   => ReadItLater::URL_BASE+'/auth'  ,
    :signup => ReadItLater::URL_BASE+'/signup',
    :api    => ReadItLater::URL_BASE+'/api'   
  }

  attr_reader :last_response
  
  class User
    attr_accessor :username, :password
    def initialize(username, password)
      @username, @password, @last_response = username, password, ""
    end
  end
  
  attr_accessor :api_key
  
  def initialize(api_key)
    @api_key = api_key
  end
  
  def add(user, url)
    @last_response = query(:add, user, :url => url)
  end
  
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
    response[:data][:status] = response[:data][:status].strip == "1" ? :normal : :no_changes 
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
    puts "="*50+"\n#{query_str}\n"+"="*50+"\n\n"
    return query_str
  end
  
  def unique_id
    return (1..24).to_a.map{|i|(('a'..'z').to_a+('0'..'9').to_a)[rand(36)]}.join
  end

  def query(method, user, params={})
    response = nil
    open(ril_api_url(method, user, params)) do |f|
      response = {
        :text => f.read.strip,
        :status => f.meta["status"].split[0].strip.to_i,
        :user => {
          :limit     => (f.meta["x-limit-user-limit"    ] || "-1").to_i,
          :remaining => (f.meta["x-limit-user-remaining"] || "-1").to_i,
          :reset     => (f.meta["x-limit-user-reset"    ] || "-1").to_i
        },
        :key => {
          :limit     => (f.meta["x-limit-key-limit"     ] || "-1").to_i,
          :remaining => (f.meta["x-limit-key-remaining" ] || "-1").to_i,
          :reset     => (f.meta["x-limit-key-reset"     ] || "-1").to_i
        },
        :error => f.meta["x-error"]
      }
    end
    return response
  end
  
  def stringify_keys(hsh)
    hsh.map{|k,v|{k.to_sym => (v.class == Hash ? stringify_keys(v) : v)}}.inject(){|a,b|a.merge(b)}
  end
  
end


