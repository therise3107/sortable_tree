# == Schema Information
#
# Table name: choices
#
#  id            :integer          not null
#  body          :text
#  correct       :boolean          default(FALSE), not null
#  evoke_id      :integer
#  explanation   :text
#  sort_order    :string
#  bodyx         :string
#  explanationx  :string
#  body_y        :string
#  explanation_y :string
#

class Choice < ActiveRecord::Base
  scope :right, -> { where(correct: true) }
  scope :wrong, -> { where('correct = false or correct is null') }

  belongs_to :evoke

  validates :body, presence: true

  def overlaid_body
    if evoke.overlay.nil?
      (evoke.vignette.present? && !evoke.vignette.overlay.nil? ? body_y % eval(evoke.vignette.overlay.to_json) : body).html_safe
    else
      (body_y % eval(evoke.overlay.to_json)).html_safe
    end
  end

  def overlaid_explanation
    if evoke.overlay.nil?
      (evoke.vignette.present? && !evoke.vignette.overlay.nil? ? explanation_y % eval(evoke.vignette.overlay.to_json) : explanation).html_safe
    else
      (explanation_y % eval(evoke.overlay.to_json)).html_safe
    end
  end
end
