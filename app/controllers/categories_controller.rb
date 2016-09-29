class CategoriesController < ApplicationController

  def index

  end

  include SortableTreeController::Sort
  sortable_tree 'Topic'

  def manage
    # fix ancestry
    #Category.build_ancestry_from_parent_ids!

    #
    @items = Topic.all.arrange(:order => :sort_order)

  end


end
