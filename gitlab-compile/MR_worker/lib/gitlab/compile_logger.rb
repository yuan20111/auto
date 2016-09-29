module Gitlab
  class CompileLogger < Gitlab::Logger
    def self.file_name_noext
      'compile'
    end
  end
end
