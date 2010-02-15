require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'read_it_later')

When /^I create a User object with a user name "([^\"]*)" and password "([^\"]*)"$/ do |username, password|
  @username = (username == "unspecified" ? nil : username)
  @password = (password == "unspecified" ? nil : password)
end

Then /^I should get a User object with no errors$/ do
  lambda {
    if @username and @password
      @user = ReadItLater::User.new(@username, @password)
    elsif @username
      @user = ReadItLater::User.new(@username)
    else
      @user = ReadItLater::User.new
    end
  }.should_not raise_error
end

Then /^The User object should have a "([^\"]*)" of "([^\"]*)"$/ do |field_name, value|
  if field_name == "user name"
    if value == "unspecified"
      @user.username.should be_nil
    else
      @user.username.should == value
    end
  else
    if value == "unspecified"
      @user.password.should be_nil
    else
      @user.password.should == value
    end
  end
end

