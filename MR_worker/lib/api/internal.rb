module API
  # Internal access API
  class Internal < Grape::API
    before { authenticate_by_gitlab_shell_token! }

    namespace 'internal' do
      # Check if git command is allowed to project
      #
      # Params:
      #   key_id - ssh key id for Git over SSH
      #   user_id - user id for Git over HTTP
      #   project - project path with namespace
      #   action - git action (git-upload-pack or git-receive-pack)
      #   ref - branch name
      #   forced_push - forced_push
      #
      post "/allowed" do
        status 200

        actor = if params[:key_id]
                  Key.find_by(id: params[:key_id])
                elsif params[:user_id]
                  User.find_by(id: params[:user_id])
                end

        unless actor
          return Gitlab::GitAccessStatus.new(false, 'No such user or key')
        end

        project_path = params[:project]

        # Check for *.wiki repositories.
        # Strip out the .wiki from the pathname before finding the
        # project. This applies the correct project permissions to
        # the wiki repository as well.
        access =
          if project_path.end_with?('.wiki')
            project_path.chomp!('.wiki')
            Gitlab::GitAccessWiki.new
          else
            Gitlab::GitAccess.new
          end

        project = Project.find_with_namespace(project_path)

        if project
          status = access.check(
            actor,
            params[:action],
            project,
            params[:changes]
          )
        end

        if project && status && status.allowed?
          status
        else
          Gitlab::GitAccessStatus.new(false, 'No such project')
        end
      end

      #
      # Discover user by ssh key
      #
      get "/discover" do
        key = Key.find(params[:key_id])
        present key.user, with: Entities::UserSafe
      end

      get "/check" do
        {
          api_version: API.version,
          gitlab_version: Gitlab::VERSION,
          gitlab_rev: Gitlab::REVISION,
        }
      end

      get "/broadcast_message" do
        if message = BroadcastMessage.current
          present message, with: Entities::BroadcastMessage
        else
          {}
        end
      end
    end
  end
end
