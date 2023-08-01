# frozen_string_literal: true

module Api
  module V1
    class BatchesController < ApplicationController
      before_action :set_batch, only: %i[show edit update destroy add_batch_request add_student]

      # GET /api/v1/batches or /api/v1/batches.json
      def index
        @batches = Batch.all
        render json: @batches
      end

  # GET /api/v1/batches/1
  def show
    render json: @batch
  end

  # POST /api/v1/batches
  def create
    @batch = Batch.new(batch_params)
    if @batch.save
      render json: @batch, status: :created
    else
      render json: @batch.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/batches/1
  def update
    if @batch.update(batch_params)
      render json: @batch
    else
      render json: @batch.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/batches/1
  def destroy
    @batch.destroy
    head :no_content
  end

  def add_batch_request
    connections = @batch.connections.where(student_id: current_user&.id, school_id: @batch&.school&.id,
     batch_id: @batch&.id)
    if connections.present?
      render json: { message: 'Batch request was already created.' }, status: :ok
    elsif @batch.connections.find_or_create_by(student_id: current_user&.id, school_id: @batch&.school&.id,
     batch_id: @batch&.id)
    render json: { message: 'Batch request was created successfully.' }, status: :created
  else
    render json: @batch.errors, status: :unprocessable_entity
  end
end

def add_student
  return unless request.post?

  student = User.find_by(id: params[:batch][:student_id])
  Connection.find_or_create_by(student_id: student.id, batch_id: @batch.id)
  head :no_content
end

private

      # Use callbacks to share common setup or constraints between actions.
      def set_batch
        @batch = Batch.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def batch_params
        params.require(:batch).permit(:name, :max_count, :school_id)
      end
    end
  end
end
