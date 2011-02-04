module Ipreader

  module Display
    
#    KNOWN_FORMATS = [ "xml", "csv", "html" ]
#    NO_TEMPLATE = "no template chosen"
#    TEMPLATE_LOCATION = "templates"
    
    @missing = ''

    def which_template(format)
     known_fmt = lambda { |item| KNOWN_FORMATS.include?(item) }
      case format
        when known_fmt
          "#{Ipreader::TEMPLATE_LOCATION}/sms.#{format.strip}.haml"
        else
          @missing = format
          "#{Ipreader::TEMPLATE_LOCATION}/sms.missing.haml"
      end
    end

    def template_location(templ)
      File.join(File.dirname(__FILE__), which_template(templ))
    end
    
    def display_sms( template_type = "html" )
      temp_loc = template_location(template_type)
      render_template(File.read(temp_loc))
    end

    def render_template( template = nil )
      unless template.nil?
        Haml::Engine.new(template).render( Object.new, :conversations => @conversations, :missing => @missing )
      else
        Ipreader::NO_TEMPLATE
      end
    end
    
  end

  
end