module Gitlab
  class RepertoryLogger < Gitlab::Logger
    def self.file_name_noext
      'repertory'
    end
  end
end
