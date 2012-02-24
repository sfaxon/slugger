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
  it "slug should be limited to 20 characters" do
    p = Post.create(
      :title => "when you write really long titles slugs should be shortened")
    p.slug.should == "when-you-write-reall"
  end
  it "slug should not end with a substitution character" do
    p = Post.create(
      :title => "when you write very long titles slugs should be shortened")
    p.slug.should == "when-you-write-very"
  end
  it "should not be valid on duplicate" do
    p = Post.create(:title => "hello")
    p.slug.should == "hello"
    q = Post.create(:title => "hello")
    q.should_not be_valid
  end
end
