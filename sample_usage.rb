#!/usr/local/bin/ruby

require "lib/read_it_later"

ril = ReadItLater.new("<Your ReadItLater API Key Here>")
usr = ReadItLater::User.new('SomeUserName', 'SomeUserPass')

# Add method
# ===================================================================================
# pp ril.add(usr, "http://www.google.com/search?q=add+to+ril")

# Send method
# ===================================================================================
# pp ril.send(usr,
#     :new => [
#       { :url => "http://www.url1.com/", :title => "URL New 1" },
#       { :url => "http://www.url2.com/", :title => "URL New 2" },
#       { :url => "http://www.url3.com/", :title => "URL New 3" }
#     ],
#     :read => [
#         { :url => "http://www.url1.com/" },
#         { :url => "http://www.url2.com/" },
#         { :url => "http://www.url3.com/" }
#     ],
#     :update_title => [
#       { :url => "http://www.url1.com/", :title => "Updated URL New 1" },
#       { :url => "http://www.url2.com/", :title => "Updated URL New 2" },
#       { :url => "http://www.url3.com/", :title => "Updated URL New 3" }
#     ],
#     :update_tags => [
#       { :url => "http://www.url1.com/", :tags => "url1tag1, url1tag2, url1tag3" },
#       { :url => "http://www.url2.com/", :tags => "url2tag1, url2tag2, url2tag3" },
#       { :url => "http://www.url3.com/", :tags => "url3tag1, url3tag2, url3tag3" }
#     ]
# )

# Stats method
# ===================================================================================
# pp ril.stats(usr)

# Get method
# ===================================================================================
# pp ril.get(usr,
#   :state => :unread, 
#   :mine_only => false, 
#   :since => (Time.now-30*24*60*60), 
#   :count => 10, 
#   :page => 2, 
#   :tags => false)

# Auth method
# ===================================================================================
# pp ril.auth(usr)

# Sign Up method
# ===================================================================================
# pp ril.auth(usr)

# API method
# ===================================================================================
# pp ril.api



