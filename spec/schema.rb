require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(
  :adapter => defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby' ? 'jdbcsqlite3' : 'sqlite3',
  :database => File.join(File.dirname(__FILE__), 'test.db')
)

class CreateSchema < ActiveRecord::Migration
  def self.up
    create_table :posts, :force => true do |t|
      t.string :title
      t.string :slug
      t.timestamps
    end

    create_table :users, :force => true do |t|
      t.string :first_name
      t.string :last_name
      t.string :slug
      t.timestamps
    end

    create_table :edges, :force => true do |t|
      t.string :name
      t.string :slug_name
    end
    create_table :comments, :force => true do |t|
      t.integer :post_id
      t.string  :title
      t.string  :slug
    end
  end
end

CreateSchema.suppress_messages do
  CreateSchema.migrate(:up)
end

class Post < ActiveRecord::Base
  has_many :comments
  has_slug 'title', :max_length => 20
end

class User < ActiveRecord::Base
  has_slug [:first_name, :last_name], :on_conflict => :append_id
end

class Edge < ActiveRecord::Base
  has_slug 'name', :slug_column => :slug_name,
                   :substitution_char => "_",
                   :downcase => false,
                   :on_conflict => :concat_random_chars
end

class Comment < ActiveRecord::Base
  belongs_to :post
  has_slug   :title, :scope => :post_id
end
