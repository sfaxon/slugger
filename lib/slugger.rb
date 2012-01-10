require 'slugger/version'
require 'active_record'
require 'iconv'

module Slugger
  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods
    def has_slug(title_column=nil,options={})
      class_attribute :slugger_options
      default_options = {
        :title_column      => 'title',
        :slug_column       => 'slug',
        :substitution_char => '-',
        :downcase          => true,
        :on_conflict       => :error
      }

      self.slugger_options = default_options.merge(options)
      self.slugger_options[:title_column] = title_column unless title_column.nil?

      if columns_hash[slugger_options[:slug_column].to_s].nil?
        raise ArgumentError, "#{self.name} is missing required " +
                             "#{slugger_options[:slug_column]} column"
      end

      before_validation :permalize, :on => :create

      validates slugger_options[:slug_column].to_sym, :presence => true

      if slugger_options[:scope]
        validates slugger_options[:slug_column].to_sym,
                  :uniqueness => { :scope => slugger_options[:scope] }
      else
        validates slugger_options[:slug_column].to_sym,
                  :uniqueness => true
      end

      send :define_method, :column_to_slug,
        lambda { self.send(slugger_options[:title_column]) }

      include InstanceMethods
    end
  end
  module InstanceMethods

    private

    def permalize
      return unless self.send("#{self.slugger_options[:slug_column]}").blank?

      if slugger_options[:title_column].is_a?(Array)
        s = ""
        self.slugger_options[:title_column].each do |m|
          s = "#{s} #{self.send(m)}"
        end
        s = Iconv.iconv('ascii//ignore//translit', 'utf-8', s).to_s
      else
        s = Iconv.iconv('ascii//ignore//translit', 'utf-8',
              self.send("#{self.slugger_options[:title_column]}")).to_s
      end

      # Remove apostrophes
      s.gsub!(/\'/, '')
      # Replace all non-word chars to spaces
      s.gsub!(/\W+/, ' ')
      s.strip!
      # Replace spaces with dashes or custom substitution character
      s.gsub!(/\ +/, slugger_options[:substitution_char].to_s)
      s.downcase! if slugger_options[:downcase]
      s = s[0..(slugger_options[:max_length] - 1)] if slugger_options[:max_length]

      self.send("#{self.slugger_options[:slug_column]}=", s)

      slug_conflict_resolution
    end

    def slug_conflict_resolution(append=nil)
      slug_column = slugger_options[:slug_column]

      # Check if there are any records which the generated slug will conflict with
      if self.class.where(slug_column => read_attribute(slug_column)).any?
        self.send("slug_conflict_resolution_#{self.slugger_options[:on_conflict]}", append)
      end
    end

    def slug_conflict_resolution_concat_random_chars(append)
      chars = ("a".."z").to_a + ("1".."9").to_a
      random_chars = Array.new(3, '').collect{chars[rand(chars.size)]}.join
      self.send("#{self.slugger_options[:slug_column]}=", "#{self.slugger_options[:slug_column]}#{self.slugger_options[:substitution_char]}#{random_chars}")
      slug_conflict_resolution
    end

    def slug_conflict_resolution_error(append)
      # no op, validation sets error
    end
  end
end

ActiveRecord::Base.send(:include, Slugger)