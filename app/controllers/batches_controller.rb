# frozen_string_literal: true

class BatchesController < ApplicationController
  before_action :set_batch, only: %i[show edit update destroy add_batch_request add_student]
  load_and_authorize_resource

  # GET /batches or /batches.json
  def index
    @batches = Batch.all
  end

  # GET /batches/1 or /batches/1.json
  def show; end

  # GET /batches/new
  def new
    @batch = Batch.new
  end

  # GET /batches/1/edit
  def edit; end

  # POST /batches or /batches.json
  def create
    @batch = Batch.new(batch_params)
    respond_to do |format|
      if @batch.save
        format.html { redirect_to batch_url(@batch), notice: 'batch was successfully created.' }
        format.json { render :show, status: :created, location: @batch }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /batches/1 or /batches/1.json
  def update
    respond_to do |format|
      if @batch.update(batch_params)
        format.html { redirect_to batch_url(@batch), notice: 'batch was successfully updated.' }
        format.json { render :show, status: :ok, location: @batch }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /batches/1 or /batches/1.json
  def destroy
    @batch.destroy

    respond_to do |format|
      format.html { redirect_to dashboards_path, notice: 'batch was successfully destroyed.' }
      format.json { success 'destroyed' }
    end
  end

  def add_batch_request
    connections = @batch.connections.where(student_id: current_user&.id, school_id: @batch&.school&.id,
                                           batch_id: @batch&.id)
    respond_to do |format|
      if connections.present?
        format.html { redirect_to list_batch_dashboards_path, notice: 'Batch requeste was already created.' }
        format.json { render :show, status: :success, location: @batch }
      elsif @batch.connections.find_or_create_by(student_id: current_user&.id, school_id: @batch&.school&.id,
                                                 batch_id: @batch&.id)
        format.html { redirect_to list_batch_dashboards_path, notice: 'Batch requeste was created successfully.' }
        format.json { render :show, status: :created, location: @batch }
      else
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_student
    return unless request.post?

    student = User.find_by(id: params[:batch][:student_id])
    Connection.find_or_create_by(student_id: student.id, batch_id: @batch.id)
    redirect_to add_student_batch_path, notice: 'Student added to Batch successfully.'
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
