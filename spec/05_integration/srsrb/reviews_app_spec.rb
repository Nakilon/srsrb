require 'srsrb/reviews_app'
require 'srsrb/object_patch'
require 'review_browser'


module SRSRB
  describe ReviewsApp do
    let (:deck_view) { mock(:deck_view_model) }
    let (:decks) { mock(:decks) }
    let (:plain_app) { ReviewsApp.new deck_view, decks }
    let (:app) { plain_app } # Rack::CommonLogger.new plain_app, $stderr }
    let (:browser) { ReviewBrowser.new app }

    let (:card) { OpenStruct.new(
      id: LexicalUUID.new, question: 'a question 1', answer: 'the answer', 
      as_json: {'canary' => true}) 
    }

    before do
      described_class.set :raise_errors, true
      described_class.set :dump_errors, false
      described_class.set :show_exceptions, false
    end

    describe "GET /reviews" do
      it "should query the next card in the deck" do
        deck_view.should_receive(:next_card_upto).with(0)
        page = browser.get_reviews_top
      end

      it "should show the question from the next card" do
        deck_view.stub(:next_card_upto).with(0).and_return(card)
        page = browser.get_reviews_top
        expect(page.question_text).to be == card.question
      end

      it "should show the done page when the deck is exhausted" do
        deck_view.stub(:next_card_upto).with(0).and_return(nil)
        page = browser.get_reviews_top
        expect(page).to be_kind_of(DeckFinishedPage)
      end

    end
    describe "GET /reviews/$id" do
      before do
      end
      it "should lookup the answer when answer requested" do
        deck_view.should_receive(:card_for).with(card.id).and_return(card)
        browser.show_answer card.id
      end

      it "should show the answer text" do
        deck_view.stub(:card_for).with(card.id).and_return(card)
        page = browser.show_answer card.id
        expect(page.answer_text).to be == card.answer
      end

      it "should include a review button that scores the card as 'good'"  do
        deck_view.stub(:card_for).with(card.id).and_return(card)
        deck_view.stub(:next_card_upto)

        page = browser.show_answer card.id

        decks.should_receive(:score_card!).with(card.id, :good)
        page.score_card :good
      end

      it "should include a review button that fails the card"  do
        deck_view.stub(:card_for).with(card.id).and_return(card)
        deck_view.stub(:next_card_upto)

        page = browser.show_answer card.id

        decks.should_receive(:score_card!).with(card.id, :fail)
        page.score_card :fail
      end

      it "should include a review button that scores the card as poor"  do
        deck_view.stub(:card_for).with(card.id).and_return(card)
        deck_view.stub(:next_card_upto)

        page = browser.show_answer card.id

        decks.should_receive(:score_card!).with(card.id, :poor)
        page.score_card :poor
      end

    end
  end
end
