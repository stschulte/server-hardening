class Harden::Template

  def self.add(name, &block)
    new_template = new(name)
    new_template.evaluate(&block)

    register(name, new_template)
  end

  def initialize(name)
    @name = name
  end

  def self.register(name, template)
    @templates ||= {}
    if @templates[name] then
      warn "Template #{name} already registered"
    else
      @templates[name] = template
    end
  end

  def self.template(name)
    @templates[name]
  end

  def evaluate(&block)
    instance_eval(&block)
  end
end
