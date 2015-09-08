#!/usr/bin/ruby

require 'harden'
require 'harden/rule'

puts "Hardening Server (Version #{Harden::VERSION})"

Harden::Rule.load_all

#status = {
#  :success   => 0,
#  :fixed     => 0,
#  :nofix     => 0,
#  :depfailed => 0,
#  :skipped   => 0
#}

Harden::Rule.each do |name, description, rule|
  puts "#{name} - \e[1m#{description}\e[21m"
  rule.run(true)
end
