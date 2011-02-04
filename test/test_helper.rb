require "minitest/unit"
require_relative "test_unit_extensions"
require "flexmock/test_unit"
require_relative "../ipreader"


def template_loc
  Ipreader::TEMPLATE_LOCATION
end

def library_loc
  Ipreader::LIBRARY_LOCATION
end

def no_template
  Ipreader::NO_TEMPLATE
end

def known_template_formats
  Ipreader::KNOWN_FORMATS
end

def app_root 
  File.expand_path(File.join(File.dirname(__FILE__),".."))
end

def test_root
  File.join(app_root,"test")
end

def templates_path
  File.join(app_root, library_loc, template_loc)
end