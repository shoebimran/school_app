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

      # GET /api/v1/batches/1 or /api/v1/batches/1.json
      def show
        render json: @batch
      end

      # POST /api/v1/batches or /api/v1/batches.json
      def create
        @batch = Batch.new(batch_params)
        if @batch.save
          render json: { message: 'Batch was successfully created.', batch: @batch }, status: :created
        else
          render json: { errors: @batch.errors }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/batches/1 or /api/v1/batches/1.json
      def update
        if @batch.update(batch_params)
          render json: { message: 'Batch was successfully updated.', batch: @batch }
        else
          render json: { errors: @batch.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/batches/1 or /api/v1/batches/1.json
      def destroy
        @batch.destroy
        head :no_content
      end

      def add_batch_request
        if @batch.connections.find_or_create_by(student_id: current_user&.id, school_id: @batch&.school&.id,
                                                batch_id: @batch&.id)
          render json: { message: 'Batch request created successfully.', batch: @batch }, status: :created
        else
          render json: { errors: @batch.errors }, status: :unprocessable_entity
        end
      end

      def add_student
        if request.post?
          student = User.find_by(id: params[:batch][:student_id])
          Connection.find_or_create_by(student_id: student.id, batch_id: @batch.id)
          render json: { message: 'Student added to Batch successfully.', batch: @batch }, status: :ok
        else
          # Handle GET request for add_student
          render json: { message: 'Provide student_id in the request body.', batch: @batch },
                 status: :unprocessable_entity
        end
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
