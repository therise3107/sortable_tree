class TopicsController < ApplicationController
  include SortableTreeController::Sort
  sortable_tree 'Topic', {parent_method: 'parent'}

  def index
    @topics = Topic.where(parent_id: nil)
    @evokes_count = Evoke.count
    @active_evokes_count = Evoke.where('active is true').count
    @inactive_evokes_count = @evokes_count - @active_evokes_count
  end

  # def show
  #   @topic = Topic.find(params[:topic_id])
  #   respond_to do |format|
  #      format.js
  #  end
  # end

  def manage
    @items = Topic.all.arrange(:order => :sort_order)
  end

end
