require 'harden/util'

class Harden::Rule

  include Harden::Util

  attr_reader :name, :description, :scored

  def self.load_all
    Dir.glob(File.join(File.dirname(__FILE__), 'rules', '*.rb')).each do |file|
      Kernel.load(file)
    end
  end

  def self.add(name, options = {}, &block)
    @collection ||= []

    new_rule = new(name, options)
    new_rule.evaluate(&block)

    @collection << new_rule
  end

  def self.each
    @collection.sort_by { |r| r.name }.each do |rule|
      yield rule.name, rule.description, rule
    end
  end

  def initialize(name, options = {})
    @name = name
    @scored = options[:scored] || false
  end

  def desc(description)
    @description = description
  end

  def check(msg, &block)
    @check_msg = msg
    @check_code = block
  end

  def fix(msg, &block)
    @fix_msg = msg
    @fix_code = block
  end
  
  def run
#    puts "  \e[34mChecking #{@check_msg}\e[0m"
    if @check_code.call
      puts "  \e[32mChecking #{@check_msg} PASSED\e[0m"
    else
      puts "  \e[37mChecking #{@check_msg} FAILED\e[0m"
      if @fix_code.is_a? Proc
        puts "  #{@fix_msg}"
        @fix_code.call
      end
    end
  end

  def evaluate(&block)
    instance_eval(&block)
  end
    
end
