require 'rubygems'
require 'ubiquity/mediasilo/api'

class MediasiloOperation < ActiveRecord::Base

  include Action

  CREATE_PROJECT  = 'Create_Project'
  CREATE_FOLDER   = 'Create_Folder'
  OPERATIONS = [ CREATE_PROJECT, CREATE_FOLDER ]
  
  DEFAULT_OPERATION = CREATE_PROJECT

  OUTPUT_FOLDER_ID  = 'Folder_Id'
  OUTPUT_PROJECT_ID = 'Project_Id'

  def self.version
    return 0, 1, 0
  end

  def category
    return [CATEGORY_SYSTEM]
  end

  def description
    return 'This action plug-ins can be used to create an object in Mediasilo with the S3 file path'
  end
  
  def inputs_spec
    @required_inputs = {}
    @optional_inputs = {}

    @required_inputs['Server'] = TYPE_STRING if hostname.blank?

    if(operation == CREATE_PROJECT)
      @required_inputs['Project_Name'] = TYPE_STRING if project_name.blank?
    elsif(operation == CREATE_FOLDER)
      @required_inputs['Project_Id'] = TYPE_STRING if project_id.blank?
      @required_inputs['Folder_Name'] = TYPE_STRING if folder_name.blank?
    end

    @optional_inputs['Username'] = TYPE_STRING
    @optional_inputs['Password'] = TYPE_STRING
    
    return @required_inputs, @optional_inputs
  end

  def outputs_spec
    outputsSpec = {}

    if(operation == CREATE_PROJECT)
      outputsSpec = {OUTPUT_PROJECT_ID => TYPE_STRING}
    elsif(operation == CREATE_FOLDER)
      outputsSpec = {OUTPUT_FOLDER_ID => TYPE_STRING}
    end
    
    return outputsSpec
  end
  
  def execute
    begin
      @outputs={}

      host = hostname
      user = username_get
      pwd = password_get

      credentials = { :hostname => host,
        :username => user,
        :password => pwd }

      args = {}
      api = Ubiquity::MediaSilo::API.new(args)

      response = api.initialize_session(credentials)
      log response.inspect

      if(operation_get == CREATE_PROJECT)
        @outputs[OUTPUT_PROJECT_ID] = create_project(api)
      elsif(operation_get == CREATE_FOLDER)
        @outputs[OUTPUT_PROJECT_ID] = create_folder(api)
      end

    rescue Exception => e
      error e.inspect
    end
  end

  def create_project(api)
    resp2 = api.project_get_all
    #log resp2.inspect

    proj_name = project_name_get
    resp3 = api.project_create(proj_name)
    log "proj creation resp: #{resp3.inspect}"

    return project_id
  end

  def create_folder(api)
    resp3 = api.folder_create(folder_name_get, project_id_get)
    log "folder creation resp: #{resp3.inspect}"

    return folder_id
  end

  def get(var)
    return default_get(var)
  end

  def project_name_get
    return default_get(:project_name)
  end

  def project_id_get
    return default_get(:project_id)
  end

  def folder_name_get
    return default_get(:folder_name)
  end

  def operation_get
    return default_get(:operation)
  end

  def username_get
    return default_get(:username)
  end

  def password_get
    return default_get(:password)
  end
  

end