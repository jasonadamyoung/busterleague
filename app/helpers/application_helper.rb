# encoding: utf-8
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def twitter_alert_class(type)
    baseclass = "alert"
    case type
    when 'warning'
      "#{baseclass} alert-warning"
    when 'error'
      "#{baseclass} alert-danger"
    when 'notice'
      "#{baseclass} alert-info"
    when 'success'
      "#{baseclass} alert-success"
    else
      "#{baseclass} #{type.to_s}"
    end
  end

  def nav_item(path,label)
    list_item_class = current_page?(path) ? 'nav-item active' : 'nav-item'
    markup = <<~MARKUP
      <li class=#{list_item_class}>
        #{link_to(label.html_safe,path,class: 'nav-link').html_safe}
      </li>
    MARKUP
    markup.html_safe
  end

  def nav_dropdown_item(path,label,experimental = false)
    dropdown_item_class = current_page?(path) && !experimental ? 'dropdown-item active' : 'dropdown-item'
    link_to(label.html_safe,path,class: dropdown_item_class).html_safe
  end

  def teams_nav_item
    path = teams_path
    nav_item(path,'Teams')
  end

  def team_nav_dropdown_item(team)
    path = team_path(team)
    nav_dropdown_item(path,team.name)
  end

end
