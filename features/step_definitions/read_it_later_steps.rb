require 'yaml'
require 'erb'
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'read_it_later')

CONFIG=YAML.load(ERB.new(File.open(File.join(File.dirname(__FILE__), '..', '..', 'config', 'test.yml')).read).result)

Given /^I have a valid API Key and User$/ do
  @api_key = CONFIG[:api_key]
  @username = CONFIG[:username]
  @password = CONFIG[:password]
end

When /^I create a ReadItLater API Object$/ do
  @ril = ReadItLater.new(@api_key)
  @usr = ReadItLater::User.new(@username, @password)
end

When /^I add a new bookmark$/ do
  @response = @ril.add(@usr, "http://www.google.com/search?q=#{rand(999999)}")
end

When /^I send several updates$/ do
  @response = @ril.send(@usr,
    :new => [
      { :url => "http://www.url1.com/", :title => "URL New 1" },
      { :url => "http://www.url2.com/", :title => "URL New 2" },
      { :url => "http://www.url3.com/", :title => "URL New 3" }
    ],
    :read => [
        { :url => "http://www.url1.com/" },
        { :url => "http://www.url2.com/" },
        { :url => "http://www.url3.com/" }
    ],
    :update_title => [
      { :url => "http://www.url1.com/", :title => "Updated URL New 1" },
      { :url => "http://www.url2.com/", :title => "Updated URL New 2" },
      { :url => "http://www.url3.com/", :title => "Updated URL New 3" }
    ],
    :update_tags => [
      { :url => "http://www.url1.com/", :tags => "url1tag1, url1tag2, url1tag3" },
      { :url => "http://www.url2.com/", :tags => "url2tag1, url2tag2, url2tag3" },
      { :url => "http://www.url3.com/", :tags => "url3tag1, url3tag2, url3tag3" }
    ]
  )
end

When /^I send a statistics request$/ do
  @response = @ril.stats(@usr)
end

Then /^I should get back a success response from RIL server$/ do
  @response[:status].should == ReadItLater::STATUS_SUCCESS
end

Then /^I should receive usual user and key limits$/ do
  @response.has_key?(:key).should be_true
  @response.has_key?(:user).should be_true
  @response.has_key?(:text).should be_true
  @response.has_key?(:status).should be_true
end

Then /^I should receive statistics of usage$/ do
  @response.has_key?(:data).should be_true
  @response[:data].has_key?(:user_since).should be_true
  @response[:data].has_key?(:count_unread).should be_true
  @response[:data].has_key?(:count_read).should be_true
  @response[:data].has_key?(:count_list).should be_true
end

