class NotesController < ApplicationController
  before_filter :load_page
  before_filter :load_note, :only => [:show, :edit, :update, :destroy]
  
  def new
    @note = @page.build_note(params[:note])
    
    respond_to do |f|
      f.html { reload_page }
      f.m
    end
  end
  
  def create
    calculate_position
    
    @note = @page.build_note(params[:note])
    @note.updated_by = current_user
    save_slot(@note) if @page.editable?(current_user) && @note.save
    
    respond_to do |f|
      if !@note.new_record?
        f.html { reload_page }
        f.js
        handle_api_success(f, @note, true)
      else
        f.js
        f.html { reload_page }
        handle_api_error(f, @note)
      end
    end
  end
  
  def show
    respond_to do |f|
      f.xml { render :xml => @note.to_xml }
      f.json{ render :as_json => @note.to_xml }
      f.yaml{ render :as_yaml => @note.to_xml }
    end
  end
  
  def edit
    respond_to{|f|f.js}
  end
  
  def update
    @note.updated_by = current_user
    
    if @note.editable?(current_user) and @note.update_attributes(params[:note])
      respond_to do |f|
        f.html { reload_page }
        f.js
        handle_api_success(f, @note)
      end
    else
      respond_to do |f|
        f.html { reload_page }
        f.js
        handle_api_error(f, @note)
      end
    end
  end
  
  def destroy
    @slot_id = @note.page_slot.id
    
    if @note.editable?(current_user)
      @note.destroy
      respond_to do |f|
        f.html { reload_page }
        f.js
        handle_api_success(f, @note)
      end
    else
      respond_to do |f|
        f.html { reload_page }
        f.js
        handle_api_error(f, @note)
      end
    end
  end
  
  private
    def load_page
      @page = @current_project.pages.find(params[:page_id])
    end
    
    def reload_page
      redirect_to project_page_path(@current_project, @page)
    end
    
    def load_note
      begin
        @note = @page.notes.find(params[:id])
      rescue
        respond_to do |f|
          f.js
          handle_api_error(f, @note)
        end
      end
    end
end