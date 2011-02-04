require_relative "test_helper"  
require_relative "../ipreader/display"

class TestDisplay < Test::Unit::TestCase

  class IpDisplay
    include Ipreader::Display
  end
  
  def setup
    @display = IpDisplay.new
    @unknown_fmt = "any-unknown-format"
  end
  
  known_template_formats.each do |fmt|
    must "respond with 'templates/sms.#{fmt}.haml' when display_format gets a known format '#{fmt}'" do
      assert_equal @display.which_template(fmt), "templates/sms.#{fmt}.haml"
    end
  end
  must "respond with missing template when display_format gets an unknown format of #{@unknown_fmt}" do
    assert_equal @display.which_template(@unknown_fmt), "templates/sms.missing.haml"
  end
  
  must "have an real life template for each of the list of known formats" do
    known_template_formats.each do |fmt|
      assert File.exists?(@display.template_location(fmt)), "template #{fmt} does not actually exist"
    end
  end
  
  must "have a library directory where the library constant defines it" do
    library_path = File.join(app_root, library_loc)
    assert File.directory?(library_path), "library #{library_path} does not actually exist"
  end

  must "have a template directory where the template_path constant defines it" do
    template_path = File.join(app_root, library_loc, template_loc)
    assert File.directory?(template_path), "template directory #{template_path} does not actually exist"
  end
  
  must "create the correct fully qualified template name" do
    assert_equal @display.template_location("html"), File.join(templates_path,"sms.html.haml")
  end

  # def display_sms(template)
  #  temp_loc = template_location(template)
  #  display_template(File.read(temp_loc))
  # end  
  #  must "read from the correct template location" do
  #    mock_template = flexmock(File).should_receive(:read).with("html").and_return(:ok)
  #    assert_equal :ok, @display.display_sms("html")
  #  end
  
  # def render_template( template = nil )
  #   unless template.nil?
  #     Haml::Engine.new(template).render( Object.new, :conversations => @conversations, :missing => @missing )
  #   else
  #     NO_TEMPLATE
  #   end
  # end  
  must "return a no template message if no template is passed" do
    assert_equal @display.render_template(nil), no_template
  end
  #  must "render the and html template correctly" do
  #  end

end