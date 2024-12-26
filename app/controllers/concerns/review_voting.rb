# frozen_string_literal: true

module ReviewVoting
  extend ActiveSupport::Concern

  def set_positive_vote
    if @vote.update_vote(Spree::ReviewVote::POSITIVE)
      handle_vote_response('positive', @review.positive_count)
    else
      handle_vote_error
    end
  end

  def set_negative_vote
    if @vote.update_vote(Spree::ReviewVote::NEGATIVE)
      handle_vote_response('negative', @review.negative_count)
    else
      handle_vote_error
    end
  end

  def flag_review
    if @vote.update_vote(Spree::ReviewVote::REPORT, params[:report_reason], request.remote_ip)
      respond_to do |format|
        format.html { redirect_to product_path(@product), notice: 'Review marked as flagged' }
        format.json {
          render json: { message: "Review marked as flagged.", flag_count: @review.flag_count, reporter: @vote.reporter_ip_address }, status: :ok
        }
      end
    else
      handle_vote_error
    end
  end

  private

  def handle_vote_response(vote_type, count)
    respond_to do |format|
      format.js { render 'reviews/update_review_votes' }
      format.html { redirect_to product_path(@product), notice: "Review marked as #{vote_type}" }
      format.json { render json: { message: "Review marked as #{vote_type}.", "#{vote_type}_count".to_sym => count }, status: :ok }
    end
  end

  def handle_vote_error
    respond_to do |format|
      format.html { redirect_to product_path(@product), alert: @vote.errors.full_messages.to_sentence }
      format.json { render json: { errors: @vote.errors.full_messages }, status: :unprocessable_entity }
    end
  end
end
