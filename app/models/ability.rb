# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin?
      can :manage, :all
    elsif user.school_admin?
      can %i[show update destroy], School
      can %i[create show edit add_student destroy update], Batch
      can %i[show edit destroy create], Course
      can %i[index approve_request list_course list_student list_school list_batch request_review new_student create_student],
          DashboardsController
      can :destroy, Connection
    elsif user.student?
      can %i[show read add_batch_request], Batch
      can %i[show read], School
      can :read, Course
      can %i[index list_course list_student list_school list_batch request_review], DashboardsController
    else
      can :read, Course
    end
  end
end
