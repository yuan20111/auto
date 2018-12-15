module EmailsHelper

  # Google Actions
  # https://developers.google.com/gmail/markup/reference/go-to-action
  def email_action(url)
    name = action_title(url)
    if name
      data = {
        "@context" => "http://schema.org",
        "@type" => "EmailMessage",
        "action" => {
          "@type" => "ViewAction",
          "name" => name,
          "url" => url,
          }
        }

      content_tag :script, type: 'application/ld+json' do
        data.to_json.html_safe
      end
    end
  end

  def action_title(url)
    return unless url
    ["merge_requests", "issues", "commit"].each do |action|
      if url.split("/").include?(action)
        return "View #{action.humanize.singularize}"
      end
    end
  end

  def add_email_highlight_css
    Rugments::Themes::Github.render(scope: '.highlight')
  end

  def color_email_diff(diffcontent)
    formatter = Rugments::Formatters::HTML.new(cssclass: 'highlight')
    lexer = Rugments::Lexers::Diff.new
    raw formatter.format(lexer.lex(diffcontent))
  end
end
