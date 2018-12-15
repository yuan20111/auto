# Specifications for behavior common to all Mentionable implementations.
# Requires a shared context containing:
# - let(:subject) { "the mentionable implementation" }
# - let(:backref_text) { "the way that +subject+ should refer to itself in backreferences " }
# - let(:set_mentionable_text) { lambda { |txt| "block that assigns txt to the subject's mentionable_text" } }

def common_mentionable_setup
  # Avoid name collisions with let(:project) or let(:author) in the surrounding scope.
  let(:mproject) { create :project }
  let(:mauthor) { subject.author }

  let(:mentioned_issue) { create :issue, project: mproject }
  let(:other_issue) { create :issue, project: mproject }
  let(:mentioned_mr) { create :merge_request, :simple, source_project: mproject }
  let(:mentioned_commit) { double('commit', sha: '1234567890abcdef').as_null_object }

  let(:ext_proj) { create :project, :public }
  let(:ext_issue) { create :issue, project: ext_proj }
  let(:other_ext_issue) { create :issue, project: ext_proj }
  let(:ext_mr) { create :merge_request, :simple, source_project: ext_proj }
  let(:ext_commit) { ext_proj.repository.commit }

  # Override to add known commits to the repository stub.
  let(:extra_commits) { [] }

  # A string that mentions each of the +mentioned_.*+ objects above. Mentionables should add a self-reference
  # to this string and place it in their +mentionable_text+.
  let(:ref_string) do
    "mentions ##{mentioned_issue.iid} twice ##{mentioned_issue.iid}, " +
    "!#{mentioned_mr.iid}, " +
    "#{ext_proj.path_with_namespace}##{ext_issue.iid}, " +
    "#{ext_proj.path_with_namespace}!#{ext_mr.iid}, " +
    "#{ext_proj.path_with_namespace}@#{ext_commit.short_id}, " +
    "#{mentioned_commit.sha[0..10]} and itself as #{backref_text}"
  end

  before do
    # Wire the project's repository to return the mentioned commit, and +nil+ for any
    # unrecognized commits.
    commitmap = { '1234567890a' => mentioned_commit }
    extra_commits.each { |c| commitmap[c.short_id] = c }
    allow(mproject.repository).to receive(:commit) { |sha| commitmap[sha] }
    set_mentionable_text.call(ref_string)
  end
end

shared_examples 'a mentionable' do
  common_mentionable_setup

  it 'generates a descriptive back-reference' do
    expect(subject.gfm_reference).to eq(backref_text)
  end

  it "extracts references from its reference property" do
    # De-duplicate and omit itself
    refs = subject.references(mproject)
    expect(refs.size).to eq(6)
    expect(refs).to include(mentioned_issue)
    expect(refs).to include(mentioned_mr)
    expect(refs).to include(mentioned_commit)
    expect(refs).to include(ext_issue)
    expect(refs).to include(ext_mr)
    expect(refs).to include(ext_commit)
  end

  it 'creates cross-reference notes' do
    mentioned_objects = [mentioned_issue, mentioned_mr, mentioned_commit,
                         ext_issue, ext_mr, ext_commit]

    mentioned_objects.each do |referenced|
      expect(Note).to receive(:create_cross_reference_note).with(referenced, subject.local_reference, mauthor, mproject)
    end

    subject.create_cross_references!(mproject, mauthor)
  end

  it 'detects existing cross-references' do
    Note.create_cross_reference_note(mentioned_issue, subject.local_reference, mauthor, mproject)

    expect(subject.has_mentioned?(mentioned_issue)).to be_truthy
    expect(subject.has_mentioned?(mentioned_mr)).to be_falsey
  end
end

shared_examples 'an editable mentionable' do
  common_mentionable_setup

  it_behaves_like 'a mentionable'

  it 'creates new cross-reference notes when the mentionable text is edited' do
    new_text = "still mentions ##{mentioned_issue.iid}, " +
      "#{mentioned_commit.sha[0..10]}, " +
      "#{ext_issue.iid}, " +
      "new refs: ##{other_issue.iid}, " +
      "#{ext_proj.path_with_namespace}##{other_ext_issue.iid}"

    [mentioned_issue, mentioned_commit, ext_issue].each do |oldref|
      expect(Note).not_to receive(:create_cross_reference_note).with(oldref, subject.local_reference,
        mauthor, mproject)
    end

    [other_issue, other_ext_issue].each do |newref|
      expect(Note).to receive(:create_cross_reference_note).with(
        newref,
        subject.local_reference,
        mauthor,
        mproject
      )
    end

    subject.save
    set_mentionable_text.call(new_text)
    subject.notice_added_references(mproject, mauthor)
  end
end
