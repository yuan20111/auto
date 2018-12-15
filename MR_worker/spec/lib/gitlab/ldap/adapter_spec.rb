require 'spec_helper'

describe Gitlab::LDAP::Adapter do
  let(:adapter) { Gitlab::LDAP::Adapter.new 'ldapmain' }

  describe :dn_matches_filter? do
    let(:ldap) { double(:ldap) }
    subject { adapter.dn_matches_filter?(:dn, :filter) }
    before { adapter.stub(ldap: ldap) }

    context "when the search is successful" do
      context "and the result is non-empty" do
        before { ldap.stub(search: [:foo]) }

        it { is_expected.to be_truthy }
      end

      context "and the result is empty" do
        before { ldap.stub(search: []) }

        it { is_expected.to be_falsey }
      end
    end

    context "when the search encounters an error" do
      before { ldap.stub(search: nil, get_operation_result: double(code: 1, message: 'some error')) }

      it { is_expected.to be_falsey }
    end
  end
end
