class EventsController < ApplicationController
  layout 'whoops'
  
  def index
    @event_group = Whoops::EventGroup.find(params[:whoops_event_group_id])
    
    events_base = @event_group.events
    unless params[:query].blank?
      conditions = Whoops::MongoidSearchParser.new(params[:query]).conditions
      events_base = events_base.where(conditions)
    end
    
    @events = events_base.desc(:event_time).paginate(
      :page => params[:page],
      :per_page => 20
    )
  end
  
  def show
    @event = Whoops::Event.find(params[:id])
    respond_to do |format|
      format.js { render :partial => 'details', :object => @event, :as => :event}
    end
  end
  
  # TODO break this out into a more metal-y controller
  def create
    headers['Access-Control-Allow-Origin']= request.env['HTTP_ORIGIN']
    headers['Access-Control-Allow-Methods']=' POST, GET, OPTIONS'
    headers['Access-Control-Max-Age']= '1000'
    headers['Access-Control-Allow-Headers']= 'Content-Type';
    
    Whoops::Event.record(params[:event])
    render :status => 200, :nothing => true
  end
end
