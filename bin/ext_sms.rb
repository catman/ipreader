#!/usr/bin/env ruby

#$:.unshift File.expand_path(File.join(File.dirname(__FILE__), ".."))

require 'optparse'
require_relative "../ipreader"

OptionParser.accept(Date, /(\d+)-(\d+)-(\d+)/) do |d, mon, day, year|
  Date.new( year.to_i, mon.to_i, day.to_i )
end

opts = OptionParser.new

opts.banner = "Usage: ext_sms [ options ]"

opts.on("-h", "--help", "-?", "show this message") do
  puts opts
  exit
end

format = "html"
opts.on("-fo", "--format FORMAT", String, "Output format, one of [html, csv, xml]") do |fmt|
  format = fmt
end

backup_path = ""
opts.on("-p", "--path PATHNAME", "Path to backup directory") do |pth|
  backup_path = pth
end

# TODO add date filters
filters = {}
opts.on("-fi", "--filters 'COLUMN_NAME:value'", String, "Filter to apply, columns [address:value, text:value]") do |fltrs|
  fltrs.scan(/(\w+):\s*(\w+)/) do |name, value|
    filters[name] = "%" + value + "%"
  end
end

begin
  ARGV << "-h" if ARGV.empty?
  opts.parse!(ARGV)
  backup_reader = Ipreader::Controller.new(backup_path, format, filters)
  puts backup_reader.start
rescue OptionParser::ParseError => e
  STDERR.puts e.message, "\n", opts
  exit(-1)
end


