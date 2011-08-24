require 'spec_helper'

describe Post do
  it "should set slug on create" do
    p = Post.create(:title => "hello world")
    p.slug.should == "hello-world"
  end
  it "should not override given slug" do
    p = Post.create(:title => "hello world", :slug => "custom-slug")
    p.slug.should == "custom-slug"
  end
  it "should remove apostrophes" do
    p = Post.create(:title => "apostrop'hes", :slug => "apostrophes")
    p.slug.should == "apostrophes"
  end
end
