# frozen_string_literal: true

module Api
  module V1
    class SchoolsController < ApplicationController
      before_action :set_school, only: %i[show edit update destroy]

      # GET /api/v1/schools or /api/v1/schools.json
      def index
        @schools = School.all
        render json: @schools
      end

      # GET /api/v1/schools/1 or /api/v1/schools/1.json
      def show
        render json: @school
      end

      # POST /api/v1/schools or /api/v1/schools.json
      def create
        @school = School.new(school_params)
        if @school.save
          render json: { message: 'School was successfully created.', school: @school }, status: :created
        else
          render json: { errors: @school.errors }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/schools/1 or /api/v1/schools/1.json
      def update
        if @school.update(school_params)
          render json: { message: 'School was successfully updated.', school: @school }
        else
          render json: { errors: @school.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/schools/1 or /api/v1/schools/1.json
      def destroy
        @school.destroy
        head :no_content
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_school
        @school = School.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def school_params
        params.require(:school).permit(:name, :address, :owner_id)
      end
    end
  end
end
