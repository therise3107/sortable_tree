# == Schema Information
#
# Table name: evokes
#
#  evoke_id    :integer          not null, primary key
#  topic_id    :integer
#  stem        :text             not null
#  tute        :text
#  sort_order  :integer          default(0), not null
#  difficulty  :integer          default(40), not null
#  active      :boolean          default(TRUE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  hint        :text
#  vignette_id :integer
#  custom      :boolean          default(FALSE)
#  source      :string           default("SG")
#  hintx       :string
#  tutex       :string
#  stemx       :string
#  stem_y      :string
#  tute_y      :string
#  hint_y      :string
#  overlay     :jsonb
#  mobile      :boolean          default(TRUE)
#  original_id :integer
#

class Evoke < ActiveRecord::Base
  self.primary_key = 'evoke_id'

  default_scope { where(active: true) }
  # default_scope { order(evoke_id: :asc) }
  scope :random, -> { order('random()') }
  scope :active, -> { where(active: true) }

  # Answer choices for this evoke
  has_many :choices, dependent: :destroy
  has_many :learnings, dependent: :destroy

  belongs_to :topic

  belongs_to :vignette

  validates :stem, presence: true

  accepts_nested_attributes_for :choices, allow_destroy: true

  has_many :evoke_smarters

  def self.accessible_attributes
    %w(evoke_id topic_id stem tute sort_order difficulty vignette active)
  end

  def choice_mix
    # lets selectively shuffle the answer choices
    # shuffle the CFA and FRM choices freely
    # sort the CPA choices by sort_order
    # sort the CA choices by id

    # disabling choice reordering for questions with I only, I and II etc answer choices
    # questions should have a boolean field to allow shuffling
    # Till then disabling this option

    if evoke_id >= 400_000_000 && evoke_id < 500_000_000
      choices.order(:id).map(&:id)
    else
      correct = choices.right.shuffle.take(rand(1..4))
      incorrect = choices.wrong.shuffle.take(4 - correct.count)
      (correct + incorrect).shuffle.sort_by(&:sort_order).map(&:id)
    end
  end

  def adapt
    lrn = Learning.answered.joins(:user)
                  .where(evoke_id: evoke_id)
                  .where('users.entity IS NULL')
                  .select('100 * count(nullif(correct, true)) / count(*) difficulty_idx')
                  .group(:evoke_id)
                  .having('count(nullif(correct, true)) > 4 and count(nullif(correct, false)) > 4')

    update_attributes difficulty: lrn[0].difficulty_idx.clamp(20, 80), custom: true unless lrn.empty?
  end

  def overlaid_stem
    if overlay.nil?
      (vignette.present? && !vignette.overlay.nil? ? stem_y % eval(vignette.overlay.to_json) : stem).html_safe
    else
      (stem_y % eval(overlay.to_json)).html_safe
    end
  end

  def overlaid_tute
    if overlay.nil?
      tute.html_safe
    else
      (tute_y % (vignette.nil? ? eval(overlay.to_json) : eval(vignette.overlay.to_json))).html_safe
    end
  end

  def overlaid_hint
    if overlay.nil?
      hint.html_safe
    else
      (hint_y % (vignette.nil? ? eval(overlay.to_json) : eval(vignette.overlay.to_json))).html_safe
    end
  end
end
