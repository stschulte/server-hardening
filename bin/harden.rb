#!/usr/bin/ruby

require 'harden'
require 'harden/rule'

puts "Hardening Server (Version #{Harden::VERSION})"

Harden::Rule.load_all
Harden::Rule.each do |name, description, rule|
  puts "#{name} - \e[1m#{description}\e[21m"
  rule.run
end
