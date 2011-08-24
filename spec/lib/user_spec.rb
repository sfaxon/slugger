require 'spec_helper'

# class User < ActiveRecord::Base
#   has_slug [:first_name, :last_name]
# end

describe User do
  it "should set slug on create when given an array" do
    u = User.create(:first_name => "Tyler", :last_name => "Durden")
    u.slug.should == "tyler-durden"
  end
end
