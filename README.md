Just include in your tracked models:

    include ProtectedRecord::ChangeRequest::Changeling
    include ProtectedRecord::ChangeLog::Changeling

and include in your user model:

    include ProtectedRecord::ChangeRequest::Changer
    include ProtectedRecord::ChangeLog::Changer

then in your controller

    # UseCase module will filter changes to protected_keys,
    # creating a "change request" rather than applying changes

    # UseCase module will allow other changes to be applied,
    # creating a "change log" entry for the observed changes

    update_result = ProtectedRecord::UseCase::Update.new({
      params: visit_params,
      protected_record: @patient_visit,
      user: current_user,
      protected_keys: %w{ visit_date do_not_resuscitate }
    }).execute!

    update_result.successful?

and call methods like

    @user.change_log_records
    @user.change_request_records
