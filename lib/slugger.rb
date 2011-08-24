require 'slugger/version'
require 'active_record'
require 'iconv'

module Slugger
  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods
    def has_slug(title_column=nil,slugger_options={})
      class_inheritable_accessor :slugger_options
      slugger_options[:title_column]      ||= title_column || 'title'
      # slugger_options[:title_column]      ||= 'title'
      slugger_options[:slug_column]       ||= 'slug'
      slugger_options[:as_param]          ||= true
      slugger_options[:substitution_char] ||= '-'
      slugger_options[:downcase]          ||= true
      self.slugger_options = slugger_options
      
      # if columns_hash[slugger_options[:title_column].to_s].nil?
      # 
      #   raise ArgumentError, "#{self.name} is missing source column"
      # end
      raise ArgumentError, "#{self.name} is missing required #{slugger_options[:slug_column]} column" if columns_hash[slugger_options[:slug_column].to_s].nil?

      before_validation :permalize, :on => :create

      validates slugger_options[:slug_column].to_sym, :presence => true
      if slugger_options[:scope]
        validates slugger_options[:slug_column].to_sym, :uniqueness => {:scope => slugger_options[:scope]}
      else
        validates slugger_options[:slug_column].to_sym, :uniqueness => true
      end

      send :define_method, :column_to_slug, lambda { self.send(slugger_options[:title_column]) }

      class << self
        def find(*args)
          if self.slugger_options[:as_param] && args.first.is_a?(String)
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
      slugger_options[:as_param] ? self.slug : self.id
    end

    protected

    def permalize
      return unless self.send("#{self.slugger_options[:slug_column]}").blank?
      if slugger_options[:title_column].is_a?(Array)
        s = ""
        self.slugger_options[:title_column].each do |m|
          s = "#{s} #{self.send(m)}"
        end
        s = Iconv.iconv('ascii//ignore//translit', 'utf-8', s).to_s
      else
        s = Iconv.iconv('ascii//ignore//translit', 'utf-8', self.send("#{self.slugger_options[:title_column]}")).to_s
      end
      s.gsub!(/\'/, '')   # remove '
      s.gsub!(/\W+/, ' ') # all non-word chars to spaces
      s.strip!            # ohh la la
      s.downcase!         if slugger_options[:downcase]
      s.gsub!(/\ +/, '-') # spaces to dashes, preferred separator char everywhere
      self.send("#{self.slugger_options[:slug_column]}=", s) 
    end
    def strip_title
      self.send("#{self.slugger_options[:title_column]}").strip!
    end
  end
end

ActiveRecord::Base.send(:include, Slugger)