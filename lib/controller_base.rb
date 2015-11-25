require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = route_params
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'wtf' if already_built_response?
    @already_built_response = true
    @session.store_session(res)
    res.header['location'] = url
    res.status = 302
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    #debugger
    raise "wtf" if already_built_response?
    @already_built_response = true
    @session.store_session(res)
    res.body = [content]
    res['Content-Type'] = content_type
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    raise 'wft' if already_built_response?
    class_name = self.class.name
    template_file = "views/#{class_name.underscore}/#{template_name}.html.erb"
    output_file = File.read(template_file)
    template = ERB.new("<%= output_file %>").result(binding)
    render_content(template, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end
