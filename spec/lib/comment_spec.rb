require 'spec_helper'

# class Comment < ActiveRecord::Base
#   belongs_to :post
#   has_slug   :title, :scope => :post_id
# end

describe Comment do
  it "should honor scope" do
    p1 = Post.create(:slug => 'hello-world')
    p2 = Post.create(:slug => 'hello-world')
    c1 = Comment.create(:post => p1, :slug => 'first-comment')
    Comment.create(:post => p2, :slug => 'first-comment').should be_valid
    Comment.create(:post => p1, :slug => 'first-comment').should_not be_valid
  end
end
