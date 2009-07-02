module Plugins
  # The Plugins::Export module will be filled in with functionality by the 
  # different export plugins installed in this dradis instance. The 
  # ExportController will expose this functionality through an standarised
  # interface.
  module Export
    # When this module is included in the ExportController, walk through all the
    # defined plugins to see if they define an Actions submodule. If they do
    # include the actions in the controller.
    def self.included(base)
      self.included_modules.each do |plugin|
        if (plugin.constants.include?('Actions'))
          base.class_eval %( include #{plugin.name}::Actions )
        end
      end
    end
  end
end

# The ExportContoller will be the centralised point from which all the 
# functionality exposed by plugins is made available to the user.
class UploadController < ApplicationController
  include Plugins::Upload
  before_filter :login_required
  before_filter :prepare_params, :except => [:list]

  # This method provides a list of all the available uploader plugins. It 
  # assumes that each export plugin inclides instance methods in the
  # Plugins::Upload mixing.
  def list
    respond_to do |format|
      format.html{ redirect_to '/' }
      format.json{ 
        list = []
        Plugins::Upload.included_modules.each do |plugin|
          list << { :name => plugin.name.underscore.humanize.gsub(/\//,' - '), :formats => [] }
        end

        render :json => list
      }
    end
  end

  private
  def prepare_params
  end
end
