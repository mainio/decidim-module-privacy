# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiative do
  subject { initiative }

  let(:organization) { create(:organization) }
  let(:initiative) { create(:initiative, organization:, author: private_user) }

  describe "#author_users" do
    let(:private_user) { create(:user, :confirmed, organization:) }
    let(:rejected_user) { create(:user, :confirmed, organization:) }
    let(:public_user) { create(:user, :confirmed, :published, organization:) }
    let(:private_member) { create(:initiatives_committee_member, :accepted, initiative:, user: private_user) }
    let(:public_member) { create(:initiatives_committee_member, :accepted, initiative:, user: public_user) }
    let(:rejected_member) { create(:initiatives_committee_member, :rejected, initiative:) }

    context "when private author" do
      it "returns public authors" do
        expect(subject.author_users).not_to include(private_member)
        expect(subject.author_users).not_to include(public_member)
        expect(subject.author_users).not_to include(rejected_member)
        expect(subject.author_users).to include(an_instance_of(Decidim::Privacy::PrivateUser))
      end
    end

    context "when public author" do
      let(:initiative) { create(:initiative, organization:, author: public_user) }

      it "returns public authors" do
        expect(subject.author_users).to include(public_user)
        expect(subject.author_users).not_to include(an_instance_of(Decidim::Privacy::PrivateUser))
        expect(subject.author_users).not_to include(private_member)
        expect(subject.author_users).not_to include(rejected_member)
      end
    end

    context "when anonymous author", :anonymity do
      let(:anonymous_user) { create(:user, :anonymous, :confirmed, organization:) }
      let(:anonymous_member) { create(:initiatives_committee_member, :accepted, initiative:, user: anonymous_user) }
      let(:initiative) { create(:initiative, organization:, author: anonymous_user) }

      it "returns public authors" do
        expect(subject.author_users).not_to include(anonymous_member)
        expect(subject.author_users).not_to include(public_member)
        expect(subject.author_users).not_to include(rejected_member)
        expect(subject.author_users).to include(an_instance_of(Decidim::Privacy::PrivateUser))
      end
    end
  end
end
