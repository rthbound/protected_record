# protected_record
## Description
protected_record will prevent changes to attributes you specify as protected. Any attempted change will be logged as a ProtectedRecord::ChangeRequest::Record. 
If any changes are allowed through the filter, protected_record will create a ProtectedRecord::ChangeLog::Record to log who changed what, and for which record.
ProtectedRecord is opt-in only. In order to update with protection, use the following: 

    result = ProtectedRecord::UseCase::Update.new({
      params: visit_params,
      protected_record: @patient_visit,
      user: current_user,
      protected_keys: %w{ visit_date do_not_resuscitate }
    }).execute!


## Usage

To get started, just include in your tracked models:

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
