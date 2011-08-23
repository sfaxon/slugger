require 'spec_helper'

describe Post do
  it "should set slug on create" do
    p = Post.create(:title => "hello world")
    p.slug.should == "hello-world"
  end
end
