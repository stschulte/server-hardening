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
    new_rule = new(name, options)
    new_rule.evaluate(&block)

    register(name, new_rule)
  end

  def self.register(name, rule)
    @collection ||= {}
    if @collection[name]
      warn "Rule #{name} is already registered. Ignore this rule"
    else
      @collection[name] = rule
    end
  end

  def self.each
    @collection.keys.sort_by { |k| k.split(/\.|\-/).map {|t| t.to_i rescue t } }.each do |name|
      yield name, @collection[name].description, @collection[name]
    end
  end

  def initialize(name, options = {})
    @name = name
    @scored = options[:scored] || false
    @dependency_met = true
    @require_reboot = options[:reboot] || false
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

  def precheck(msg = nil, &block)
    @precheck_msg = msg || "precheck #{name}"
    @precheck_code = block
  end

  def depends(&block)
    @dependency_met = false unless block.call
  end

  def template(name, options)
    if template = Harden::Template.template(name) then
      extend template
      render(options)
    end
  end

  def run(autofix = true)
    if @precheck_code
      print "  \e[37mPrecheck #{@precheck_msg}\e[0m "
      if @precheck_code.call
        puts "- PASSED"
      else
        puts "- FAILED"
        return false
      end
    end

    print "  \e[34mChecking #{@check_msg}\e[0m "
    if @dependency_met
      if @check_code.call
        puts "- \e[32mPASSED\e[0m"
      else
        if @fix_code.is_a?(Proc)
          if autofix
            puts "- \e[33mAUTOMATIC FIX\e[0m"
            @fix_code.call
          else
            puts "- \e[33mFIX MANUALLY (automatic disabled)\e[0m"
          end
        else
          puts "- \e[31mFIX MANUALLY\e[0m"
        end
      end
    else
      puts "-  \e[37mSKIPPED\e[0m"
    end
  end

  def evaluate(&block)
    instance_eval(&block)
  end
    
end
