class RootController < ApplicationController

  before_filter :load_reflection

  def show
    @action = @reflection.action_by_dashed_id(params[:slug])
  end

  def index
    respond_to do |wants|
      wants.json { render :json => @reflection.as_hash }
      wants.html
    end
  end

  protected

  def load_reflection
    @reflection ||= OReflect.load_file(Rails.root + 'config' + 'reflection.rb')
  end

end
