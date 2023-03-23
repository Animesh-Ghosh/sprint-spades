# frozen_string_literal: true

require "rails_helper"

RSpec.describe GameRoomsHelper, type: :helper do
  let(:game_room) { create(:game_room) }
  let(:user) { create(:user) }
  let(:issue) { create(:issue, game_room: game_room) }
  let(:poker) { create(:poker, issue: issue, user: user) }

  describe "#generate_invitation_url" do
    it "returns the correct url" do
      expect(helper.generate_invitation_url(game_room)).to eq("http://test.host/game_rooms/join/#{game_room.token}")
    end
  end

  describe "#player_status" do
    context "when user has not voted" do
      it "returns the correct text" do
        expect(helper.player_status(user, issue)).to eq(tag.span("Not voted", class: 'badge bg-secondary'))
      end
    end

    context "when user has voted" do
      before do
        poker
      end

      context "when points are not revealed" do
        it "returns the correct text" do
          expect(helper.player_status(user, issue)).to eq(tag.span("Voted", class: "badge bg-success"))
        end
      end

      context "when points are revealed" do
        before do
          issue.update(points_revealed_at: Time.now)
        end

        context "when poker has remarks" do
          before do
            poker.update(remarks: "Some remarks")
          end

          it "returns the correct text" do
            expect(helper.player_status(user, issue)).to eq(tag.div(class:"d-flex align-items-center justify-content-between") do
              tag.span("Voted with #{pluralize(poker.story_points, 'point')}", class: "badge bg-success") +
              link_to(
                "See Remarks",
                game_room_poker_path(issue.game_room, poker),
                class: "btn btn-sm btn-outline-secondary",
                data: { turbo_frame: "modal" }
              )
            end)
          end
        end

        context "when poker does not have remarks" do
          it "returns the correct text" do
            puts helper.player_status(user, issue)
            expect(helper.player_status(user, issue)).to include(tag.span("Voted with #{poker.story_points} point", class: "badge bg-success"))
          end
        end
      end
    end
  end

  describe "#vote_details_helper" do
    context "when poker is not persisted" do
      let(:new_poker) { build(:poker) }
      it "returns the correct text and path" do
        expect(helper.vote_details_helper(new_poker, issue)).to eq({ text: "Vote", path: new_game_room_poker_path(issue.game_room) }.with_indifferent_access)
      end
    end

    context "when poker is persisted" do
      before do
        poker
      end

      it "returns the correct text and path" do
        expect(helper.vote_details_helper(poker, issue)).to eq({ text: "Update Vote", path: edit_game_room_poker_path(issue.game_room, poker) }.with_indifferent_access)
      end
    end
  end
end