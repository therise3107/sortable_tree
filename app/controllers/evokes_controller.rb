class EvokesController < ApplicationController
  def show
    @evoke = Evoke.find(params[:id])
    respond_to do |format|
       format.js
   end
  end
end
