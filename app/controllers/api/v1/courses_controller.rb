# frozen_string_literal: true

module Api
  module V1
    class CoursesController < ApplicationController
      before_action :set_course, only: %i[show edit update destroy]

      # GET /api/v1/courses or /api/v1/courses.json
      def index
        @courses = Course.all
        render json: @courses
      end

      # GET /api/v1/courses/1 or /api/v1/courses/1.json
      def show
        render json: @course
      end

      # POST /api/v1/courses or /api/v1/courses.json
      def create
        @course = Course.new(course_params)
        if @course.save
          render json: { message: 'Course was successfully created.', course: @course }, status: :created
        else
          render json: { errors: @course.errors }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/courses/1 or /api/v1/courses/1.json
      def update
        if @course.update(course_params)
          render json: { message: 'Course was successfully updated.', course: @course }
        else
          render json: { errors: @course.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/courses/1 or /api/v1/courses/1.json
      def destroy
        @course.destroy
        head :no_content
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_course
        @course = Course.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def course_params
        params.require(:course).permit(:name, :sub_name, :start_at, :end_at, :fees, :tutor_name, :course_duration,
                                       :description, :batch_id)
      end
    end
  end
end
