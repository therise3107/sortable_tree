# == Schema Information
#
# Table name: vignettes
#
#  id          :integer          not null
#  body        :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  custom      :boolean          default(FALSE)
#  bodyx       :string
#  body_y      :string
#  overlay     :jsonb
#  original_id :integer
#

class Vignette < ApplicationRecord
  has_many :evokes

  accepts_nested_attributes_for :evokes

  def overlaid
    if overlay.nil?
      body.html_safe
    else
      (body_y % eval(overlay.to_json)).html_safe
    end
  end
  
end
