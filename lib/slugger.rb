require 'slugger/version'
require 'active_record'
require 'iconv'

module Slugger
  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods
    def has_slug(title_column=nil,sluger_options={})
      class_inheritable_accessor :sluger_options
      sluger_options[:title_column]      ||= title_column || 'title'
      # sluger_options[:title_column]      ||= 'title'
      sluger_options[:slug_column]       ||= 'slug'
      sluger_options[:as_param]          ||= true
      sluger_options[:substitution_char] ||= '-'
      self.sluger_options = sluger_options
      
      # if columns_hash[sluger_options[:title_column].to_s].nil?
      # 
      #   raise ArgumentError, "#{self.name} is missing source column"
      # end
      raise ArgumentError, "#{self.name} is missing required slug column" if columns_hash[sluger_options[:slug_column]].nil?

      before_validation :create_slug, :on => :create

      validates sluger_options[:slug_column].to_sym, :presence => true
      if sluger_options[:scope]
        validates sluger_options[:slug_column].to_sym, :uniqueness => {:scope => sluger_options[:scope]}
      else
        validates sluger_options[:slug_column].to_sym, :uniqueness => true
      end

      send :define_method, :column_to_slug, lambda { self.send(sluger_options[:title_column]) }

      class << self
        def find(*args)
          if self.sluger_options[:as_param] && args.first.is_a?(String)
            find_by_slug(args)
          else
            super(*args)
          end
        end
      end
    
      include InstanceMethods
    end
  end
  module InstanceMethods

    def to_param
      sluger_options[:as_param] ? self.slug : self.id
    end

    protected

    def permalize
      return if !self.send("#{self.sluggable_conf[:slug_column]}").blank?
      s = Iconv.iconv('ascii//ignore//translit', 'utf-8', self.send("#{self.sluggable_conf[:title_column]}")).to_s
      s.gsub!(/\'/, '')   # remove '
      s.gsub!(/\W+/, ' ') # all non-word chars to spaces
      s.strip!            # ohh la la
      s.downcase!         #
      s.gsub!(/\ +/, '-') # spaces to dashes, preferred separator char everywhere
      self.send("#{self.sluggable_conf[:slug_column]}=", s) 
    end
    def strip_title
      self.send("#{self.sluggable_conf[:title_column]}").strip!
    end
    
    def create_slug
      self.slug ||= clean("#{column_to_slug}")
    end
  
    def clean(string)
      string.downcase.gsub(/[^\w\s\d\_\-]/,'').gsub(/\s\s+/,' ').gsub(/[^\w\d]/, sluger_options[:substitution_char])
    end
  end
end

ActiveRecord::Base.send(:include, Slugger)