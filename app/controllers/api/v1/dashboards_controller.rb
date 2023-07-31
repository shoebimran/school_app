# frozen_string_literal: true

module Api
  module V1
    class DashboardsController < ActionController::API
      before_action :set_connection, only: %i[approve_request]
      before_action :set_user, only: %i[edit update destroy]

      # GET /api/v1/dashboards
      def index
        if current_user.student?
          @list_schools = current_user.schools.student_school
        elsif current_user.school_admin?
          @school = current_user.own_school
        else
          @list_schools = School.all.includes(:owner)
        end
        render json: { list_schools: @list_schools, school: @school }
      end

      def new
        @school_admin = User.new
        render json: @school_admin
      end

      def create
        @school_admin = User.create(user_params)
        if @school_admin.save
          render json: @school_admin, status: :created, location: @school_admin
        else
          render json: @school_admin.errors, status: :unprocessable_entity
        end
      end

      def edit
        render json: @school_admin
      end

      def update
        if @school_admin.update(user_params)
          render json: @school_admin, status: :ok, location: @school_admin
        else
          render json: @school_admin.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @school_admin.destroy
        head :no_content
      end

      def add_batch_request
        if Connection.find_or_create_by(
          student_id: current_user&.id,
          school_id: @course&.batch&.school&.id,
          batch_id: @course&.batch&.id
        )
          render json: @course, status: :created, location: @course
        else
          render json: @course.errors, status: :unprocessable_entity
        end
      end

      def request_review
        @request_review = if current_user.student?
                            current_user.connections.student_connection(current_user&.id)
                          elsif current_user.school_admin?
                            Connection.school_admin_connection(current_user.own_school&.id)
                          else
                            Connection.all.includes(%i[course batch student school])
                          end
        render json: @request_review
      end

      def list_batch
        if current_user.student?
          @list_batch = current_user.batches.student_batch
          @school_admin_batch = Batch.school_admin_batch(current_user.schools&.ids)
        elsif current_user.school_admin?
          @school_admin_batch = Batch.school_admin_batch(current_user.own_school&.id)
        else
          @list_batch = Batch.all.includes(:school)
        end
        render json: { list_batch: @list_batch, school_admin_batch: @school_admin_batch }
      end

      def list_course
        authorize! :list_course, self
        @list_course = if current_user.student?
                         current_user.courses.student_course
                       elsif current_user.school_admin?
                         Course.school_admin_course(current_user.own_school&.id)
                       else
                         Course.all.includes(:batch)
                       end
        render json: @list_course
      end

      def list_school
        if current_user.student?
          @list_schools = current_user.schools.student_school
        elsif current_user.school_admin?
          @school = current_user.own_school
        else
          @list_schools = School.all.includes(:owner)
        end
        render json: { list_schools: @list_schools, school: @school }
      end

      def list_school_admin
        @list_school_admins = User.where(role: 1)
        render json: @list_school_admins
      end

      def list_student
        if current_user.student?
          current_user_batches = current_user.batches.pluck(:id)
          @list_students = User.student.joins(:batches).where(batches: { id: current_user_batches })
                               .where.not(id: current_user.id)
                               .distinct
        elsif current_user.school_admin?
          @list_students = current_user.own_school.students.student.distinct
        else
          @list_students = User.where(role: 0)
        end
        render json: @list_students
      end

      def approve_request
        if @connection.update(status: true)
          render json: @connection, status: :created, location: @connection
        else
          render json: @connection.errors, status: :unprocessable_entity
        end
      end

      def new_student
        @student = User.new
        render json: @student
      end

      def create_student
        @student = User.create(user_params)
        @connection = Connection.create(school_id: current_user&.schools&.first&.id)
        if @student.save
          render json: @student, status: :created, location: @student
        else
          render json: @student.errors, status: :unprocessable_entity
        end
      end

      private

      def set_course
        @course = Batch.find(params[:id])
      end

      def set_connection
        @connection = Connection.find(params[:id])
      end

      def set_user
        @school_admin = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :password, :role)
      end
    end
  end
end
