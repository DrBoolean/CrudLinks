module Crudlink::ViewHelper
  def crudlinks(options={}, &blk)
    @crudlink_options = options
    cap = block_given? ? capture(&blk) : ''
    content_for(:link_content) {cap}
  end
end


class Crudlinks  
  
  def initialize(template, controller, options={})
    options ||= {} # Don't ask
    @template, @controller = template, controller
    set_instance_by_controller_name
    @link_controller = (options[:controller_name] || @name.pluralize)
    @hide = (options[:hide] || false)
  end
  
  
  def edit_link
    path = {:controller => @link_controller, :action => "edit", :id => @instance}
    link_to("Edit #{@name.titleize}", path, :class => "button edit")
  end
  
  
  def extract_links(links="")
    @extra_links ||= links.scan(/<a.*?>.*?<\/a>/) rescue []
  end
  
  
  def delete_link
    path = {:controller => @link_controller, :action => "destroy", :id => @instance}
    link_to("Delete #{@name.titleize}", path, :confirm => 'Are you sure?', :method => :delete, :class => "button delete")
  end
  
  
  def index_link
    path = {:controller => @link_controller, :action => "index"}
    link_to("Back to index", path, :class => "button list")
  end
  
  
  def new_link
    path = {:controller => @link_controller, :action => "new"}
    link_to("Create #{@name.titleize}", path, :class => "button new")
  end
  
  
  def show_link
    path = {:controller => @link_controller, :action => "show", :id => @instance}
    link_to("Back to show", path, :class => "button list")
  end
  

  def to_html(&blk)
    extract_links(blk.call)
    action_links = {:index => [new_link], :new => [index_link], :edit => [show_link, index_link], :show => [edit_link, delete_link, index_link], :search => [index_link] }
    @extra_links.unshift(action_links[params[:action].to_sym]) unless @hide
    content_tag(:ul, (@extra_links.flatten.compact.map{ |link| content_tag(:li, link) }), :class => 'crud_links')
  end
  
  
  def method_missing(*args, &block)
    @template.send(*args, &block)
  end
  
private

  # Finds an instance variable named after the controller if there is one.
  # 
  def set_instance_by_controller_name
    @name = @controller.controller_name.singularize
    @instance = get_instance_variable(@name)
  end


  def get_instance_variable(variable)
    @controller.instance_variable_get("@#{variable}") if @controller.instance_variables.include?("@#{variable}")
  end
end
