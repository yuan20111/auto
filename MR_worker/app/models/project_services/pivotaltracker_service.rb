# == Schema Information
#
# Table name: services
#
#  id         :integer          not null, primary key
#  type       :string(255)
#  title      :string(255)
#  project_id :integer
#  created_at :datetime
#  updated_at :datetime
#  active     :boolean          default(FALSE), not null
#  properties :text
#  template   :boolean          default(FALSE)
#

class PivotaltrackerService < Service
  include HTTParty

  prop_accessor :token
  validates :token, presence: true, if: :activated?

  def title
    'PivotalTracker'
  end

  def description
    'Project Management Software (Source Commits Endpoint)'
  end

  def to_param
    'pivotaltracker'
  end

  def fields
    [
      { type: 'text', name: 'token', placeholder: '' }
    ]
  end

  def execute(push)
    url = 'https://www.pivotaltracker.com/services/v5/source_commits'
    push[:commits].each do |commit|
      message = {
        'source_commit' => {
          'commit_id' => commit[:id],
          'author' => commit[:author][:name],
          'url' => commit[:url],
          'message' => commit[:message]
        }
      }
      PivotaltrackerService.post(
        url,
        body: message.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'X-TrackerToken' => token
        }
      )
    end
  end
end
