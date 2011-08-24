require 'spec_helper'

# class Edge < ActiveRecord::Base
#   has_slug 'name', :slug_column => :slug_name,
#                    :as_param => false,
#                    :substitution_char => "_",
#                    :downcase => false,
#                    :on_conflict => :concat_random_chars
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
  it "should honor changing substitution_char" do
    e = Edge.create(:name => "with spaces")
    e.slug_name.should == "with_spaces"
  end
  it "should concat random chars when conflict" do
    e = Edge.create(:name => "dupable")
    e.slug_name.should == "dupable"
    f = Edge.create(:name => e.slug_name)
    f.should be_valid
    f.slug_name.should_not == e.slug_name
  end
end
