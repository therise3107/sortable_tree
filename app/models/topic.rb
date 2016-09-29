# == Schema Information
#
# Table name: topics
#
#  topic_id        :integer          not null, primary key
#  parent_id       :integer
#  symbol          :string           default(""), not null
#  name            :string           not null
#  description     :text
#  sort_order      :integer          default(0), not null
#  ancestry        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  ancestry_depth  :integer          default(0)
#  parent_topic_id :integer
#  active          :boolean          default(FALSE)
#  weight          :decimal(, )
#  expandable      :boolean          default(FALSE)
#  original_id     :integer
#

class Topic < ActiveRecord::Base

  

  self.primary_key = 'topic_id'

  has_ancestry orphan_strategy: :adopt, cache_depth: true

  default_scope { where(active: true).order(sort_order: :asc) }
  scope :active, -> { where(active: true) }

  # Managers of this topic
  has_many :managements, as: :manageable, dependent: :destroy
  has_many :managers, through: :managements, source: :user

  # Evokes this topic contains
  has_many :evokes, dependent: :destroy

  # Enrolments
  has_many :enrolments, dependent: :destroy
  has_many :enrolled_groups, through: :enrolments, source: :enrollable, source_type: 'Group'
  has_many :enrolled_users, through: :enrolments, source: :enrollable, source_type: 'User'

  has_many :learnings, dependent: :destroy
  has_many :proficiencies, dependent: :destroy

  # validates :name, uniqueness: true

  def self.accessible_attributes
    %w(topic_id parent_topic_id symbol name description sort_order active)
  end

  def max_depth
    subtree.select(&:is_childless?).map(&:depth).max
  end
end
