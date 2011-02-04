#!/usr/bin/env ruby

#$:.unshift File.expand_path(File.join(File.dirname(__FILE__), ".."))

format = "html"

backup_path = ARGV[0] if ARGV.length >= 1
format = ARGV[1] if ARGV.length == 2

require_relative "../ipreader"

backup_reader = Ipreader::Controller.new(backup_path, format)

sms_list = backup_reader.start

puts sms_list
