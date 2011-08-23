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
  end
end

CreateSchema.suppress_messages do
  CreateSchema.migrate(:up)
end

class Post < ActiveRecord::Base
  acts_as_sluggable
end

class User < ActiveRecord::Base
  acts_as_sluggable [:first_name, :last_name]

  def name
    [first_name, last_name].compact.join(' ')
  end

  def name=(names)
    self[:first_name], self[:last_name] = names.split(' ', 2)
  end
end
