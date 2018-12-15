require 'sidekiq/testing'

Sidekiq::Testing.inline! do
  Gitlab::Seeder.quiet do
    project_urls = [
      'https://github.com/documentcloud/underscore.git',
      'https://gitlab.com/gitlab-org/gitlab-ce.git',
      'https://gitlab.com/gitlab-org/gitlab-ci.git',
      'https://gitlab.com/gitlab-org/gitlab-shell.git',
      'https://gitlab.com/gitlab-org/gitlab-test.git',
      'https://github.com/twitter/flight.git',
      'https://github.com/twitter/typeahead.js.git',
      'https://github.com/h5bp/html5-boilerplate.git',
    ]

    project_urls.each_with_index do |url, i|
      group_path, project_path = url.split('/')[-2..-1]

      group = Group.find_by(path: group_path)

      unless group
        group = Group.new(
          name: group_path.titleize,
          path: group_path
        )
        group.description = Faker::Lorem.sentence
        group.save

        group.add_owner(User.first)
      end

      project_path.gsub!(".git", "")

      params = {
        import_url: url,
        namespace_id: group.id,
        name: project_path.titleize,
        description: Faker::Lorem.sentence,
        visibility_level: Gitlab::VisibilityLevel.values.sample
      }

      project = Projects::CreateService.new(User.first, params).execute

      if project.valid?
        print '.'
      else
        puts project.errors.full_messages
        print 'F'
      end
    end
  end
end
