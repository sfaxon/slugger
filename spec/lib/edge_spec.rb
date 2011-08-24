require 'spec_helper'

# class Edge < ActiveRecord::Base
#   has_slug 'name', :slug_column => :slug_name,
#                    :as_param => false,
#                    :substitution_char => "_",
#                    :downcase => false
# end

describe Edge do
  it "should set slug on create" do
    e = Edge.create(:name => "hello")
    e.slug_name.should == "hello"
  end
  it "should honor downcase false" do
    e = Edge.create(:name => "YELLING")
    e.slug_name.should == "YELLING"
  end

end
