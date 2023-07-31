# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action :set_connection, only: %i[approve_request]
  before_action :set_user, only: %i[edit update destroy]
  before_action :authorize_user

  # GET /dashboards or /dashboards.json
  def index
    if current_user.student?
      @list_schools = current_user.schools.student_school
    elsif current_user.school_admin?
      @school = current_user.own_school
    else
      @list_schools = School.all.includes(:owner)
    end
  end

  def new
    @school_admin = User.new
  end

  def create
    # @school_admin = User.find_or_create_by(user_params)
    @school_admin = User.create(user_params)
    respond_to do |format|
      if @school_admin.save
        format.html { redirect_to dashboards_path, notice: 'School Admin was successfully created.' }
        format.json { render :show, status: :created, location: @school_admin }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @school_admin.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @school_admin.update(user_params)
        format.html { redirect_to dashboards_path, notice: 'School Admin was successfully updated.' }
        format.json { render :show, status: :ok, location: @school_admin }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @school_admin.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @school_admin.destroy

    respond_to do |format|
      format.html { redirect_to dashboards_path, notice: 'School admin was successfully destroyed.' }
      format.json { success 'destroyed' }
    end
  end

  def add_batch_request
    respond_to do |format|
      if Connection.find_or_create_by(student_id: current_user&.id, school_id: @course&.batch&.school&.id,
                                      batch_id: @course&.batch&.id)
        format.html { redirect_to list_batch_dashboards_path, notice: 'Batch requeste was created successfully.' }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
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
  end

  def list_course
    authorize! :list_course, self
    @list_course = if current_user.student?
                     current_user.courses.student_course
                   elsif current_user.school_admin?
                     Course.school_admin_course(current_user.own_school&.id)
                   else
                     Course.all.includes(%i[batch])
                   end
  end

  def list_school
    if current_user.student?
      @list_schools = current_user.schools.student_school
    elsif current_user.school_admin?
      @school = current_user.own_school
    else
      @list_schools = School.all.includes(:owner)
    end
  end

  def list_school_admin
    @list_school_admins = User.where(role: 1)
  end

  def list_student
    if current_user.student?
      current_user_batches = current_user.batches.pluck(:id)
      @list_students = User.student.joins(:batches).where(batches: { id: current_user_batches })
                           .distinct
    elsif current_user.school_admin?
      @list_students = current_user.own_school&.students&.student&.distinct
    else
      @list_students = User.where(role: 0)
    end
  end

  def approve_request
    respond_to do |format|
      if @connection.update(status: true)
        format.html { redirect_to root_path, notice: 'Batch request approved successfully.' }
        format.json { render :show, status: :created, location: @connection }
      else
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: @connection.errors, status: :unprocessable_entity }
      end
    end
  end

  def new_student
    @student = User.new
  end

  def create_student
    @student = User.create(user_params)
    @connection = Connection.create(student_id: @student.id, school_id: current_user&.own_school&.id, status: true)
    respond_to do |format|
      if @student.save
        format.html { redirect_to list_student_dashboards_path, notice: 'New student successfully created.' }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new_student, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def authorize_user
    authorize! params[:action].to_sym, self
  end

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
