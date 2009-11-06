module TasksHelper

  def task_link(project,task_list,task)
    action = task.new_record? ? 'new' : 'edit'

    link_to_function t("tasks.link.#{action}"), show_task(project,task_list,task),
      :class => "#{action}_task_link",
      :id => task_id("#{action}_link",project,task_list,task)
  end

  def show_destroy_task_message(task)
    page.replace 'show_task', :partial => 'tasks/destroy_message', :locals => {
      :task => task }
  end

  def task_submit(project,task_list,task)
    action = task.new_record? ? 'new' : 'edit'
    submit_id = task_id("#{action}_submit",project,task_list,task)
    loading_id = task_id("#{action}_loading",project,task_list,task)
    submit_to_function t("tasks.#{action}.submit"), hide_task(project,task_list,task), submit_id, loading_id
  end
  
  def hide_task(project,task_list,task)
    action = task.new_record? ? 'new' : 'edit'
    
    header_id = task_id("#{action}_header",project,task_list,task)
    link_id = task_id("#{action}_link",project,task_list,task)
    form_id = task_id("#{action}_form",project,task_list,task)
    
    update_page do |page|
      task.new_record? ? page[link_id].show : page[header_id].show
      page[form_id].hide
      page << "Form.reset('#{form_id}')"
    end  
  end

  def task_form(project,task_list,task)
    render :partial => 'tasks/form', :locals => {
      :project => project,
      :task_list => task_list,
      :task => task }
  end

  def show_task(project,task_list,task)    
    action = task.new_record? ? 'new' : 'edit'
    
    header_id = task_id("#{action}_header",project,task_list,task)
    link_id = task_id("#{action}_link",project,task_list,task)
    form_id = task_id("#{action}_form",project,task_list,task)
    
    update_page do |page|
      task.new_record? ? page[link_id].hide : page[header_id].hide
      page[form_id].show
      page << "Form.reset('#{form_id}')"
      page << "$('#{form_id}').auto_focus()"
    end
  end  
  
  def task_form_for(project,task_list,task,&proc)
    raise ArgumentError, "Missing block" unless block_given?
    action = task.new_record? ? 'new' : 'edit'
      
    remote_form_for([project,task_list,task],
      :loading => task_form_loading(action,project,task_list,task),
      :html => {
        :id => task_id("#{action}_form",project,task_list,task), 
        :class => 'task_form', 
        :style => 'display: none;'}, 
        &proc)
  end

  def task_form_loading(action,project,task_list,task)
    update_page do |page|
      page[task_id("#{action}_submit",project,task_list,task)].hide
      page[task_id("#{action}_loading",project,task_list,task)].show
    end    
  end

  def task_id(element,project,task_list,task=nil)
    if task.nil? or (task and task.new_record?)
      "#{js_id([project,task_list,task])}_task_#{"#{element}" unless element.nil?}"
    else  
      "#{js_id([project,task_list,task])}_#{"#{element}" unless element.nil?}"
    end
  end

  def task_header(project,task_list,task)
    render :partial => 'tasks/header', :locals => {
      :project => project,
      :task_list => task_list,
      :task => task } 
  end

  def update_task_status(task)
    page.replace 'task_status', task_status(task.status) if task.class.to_s == 'Task'
  end

  def task_status(status)
    "<span class='task_status task_status_#{Task::STATUSES[status.to_i].underscore}'><span>#{Task::STATUSES[status.to_i].capitalize}</span></span>"
  end
    
  def task_status_image(status)
    image_tag("status_#{Task::STATUSES[status.to_i].underscore}.png", :class => 'task_status')
  end
      
  def my_tasks_link
    link_to 'My Tasks', ''
  end

  def delete_task_link(project,task_list,task)
    link_to_remote t('common.delete'), 
      :url => project_task_list_task_path(project,task_list,task),
      :loading => delete_task_loading(project,task_list,task),
      :confirm => t('confirm.delete_task'), 
      :method => :delete
  end

  def delete_task_loading(project,task_list,task)
    edit_actions_id = task_id('edit_actions',project,task_list,task)
    delete_loading_id = task_id('delete_loading',project,task_list,task)
    update_page do |page|
      page[edit_actions_id].hide
      page[delete_loading_id].show
    end  
  end

  def task_action_links(project,task_list,task)
    if task.owner?(current_user)
      render :partial => 'tasks/actions',
      :locals => { 
        :project => project,
        :task_list => task_list,
        :task => task }
    end
  end

  def task_list_drag_link(task_list)
    drag_image if task_list.owner?(current_user)
  end


  def task_drag_link(task)
    drag_image if task.owner?(current_user)
  end

  def list_tasks(project,task_list,tasks,current_target=nil)
    render :partial => 'tasks/task', 
      :collection => tasks,:locals => {
        :project => project,
        :task_list => task_list,
        :current_target => current_target }
  end

  def task_fields(f,project,task_list,task)
    render :partial => 'tasks/fields', :locals => { 
      :f => f,
      :project => project,
      :task_list => task_list,
      :task => task }
  end

  def render_task(project,task_list,task)
    render :partial => 'tasks/show', :locals => { :project => project, :task_list => task_list, :task => task }
  end

  def update_active_task(project,task_list,task)
    page.replace_html 'content', :partial => 'tasks/show', 
      :locals => { 
        :project => project,
        :task_list => task_list,
        :task => task }

    item_id = task_id(:item,project,task_list,task)
    page.select('.task').invoke('removeClassName','active_task')
    page.select('.task_list').invoke('removeClassName','active_task_list')
    page[item_id].addClassName('active_task')
  end
  
  def insert_task(project,task_list,task)  
    page.insert_html :bottom, task_list_id(:the_tasks,project,task_list),
      :partial => 'tasks/task', 
      :locals => {  
        :task => task,
        :project => project, 
        :task_list => task_list,
        :current_target => nil }
  end  
  
  def replace_task(project,task_list,task)
    page.replace task_id(:item,project,task_list,task),
      :partial => 'tasks/task', 
      :locals => { 
        :project => project,
        :task_list => task_list,
        :task => task,
        :current_target => task }
  end

  def replace_task_header(project,task_list,task)
    page.replace task_id(:edit_header,project,task_list,task),
      :partial => 'tasks/header', 
      :locals => { 
        :project => project,
        :task_list => task_list,
        :task => task }
  end
    
end