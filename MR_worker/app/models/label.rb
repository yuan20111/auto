# == Schema Information
#
# Table name: labels
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  color      :string(255)
#  project_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class Label < ActiveRecord::Base
  DEFAULT_COLOR = '#428BCA'

  belongs_to :project
  has_many :label_links, dependent: :destroy
  has_many :issues, through: :label_links, source: :target, source_type: 'Issue'

  validates :color,
            format: { with: /\A#[0-9A-Fa-f]{6}\Z/ },
            allow_blank: false
  validates :project, presence: true

  # Don't allow '?', '&', and ',' for label titles
  validates :title,
            presence: true,
            format: { with: /\A[^&\?,&]+\z/ },
            uniqueness: { scope: :project_id }

  default_scope { order(title: :asc) }

  alias_attribute :name, :title

  def open_issues_count
    issues.opened.count
  end
end
