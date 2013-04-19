Previous (current?) usage:

    # UseCase module will filter changes to protected_keys,
    # creating a "change request" rather than applying changes

    # UseCase module will allow other changes to be applied,
    # creating a "change log" entry for the observed changes
 
    update_result = UseCase::ProtectedRecord::Update.new({
      params: visit_params,
      protected_record: @patient_visit,
      user: current_user,
      protected_keys: %w{ visit_date do_not_resuscitate }
    }).execute!
 
    update_result.successful?
