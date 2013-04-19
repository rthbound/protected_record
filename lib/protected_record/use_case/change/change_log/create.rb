module ProtectedRecord
  module UseCase
    module Change
      module ChangeLog
        class Create < ::ProtectedRecord::UseCase::Base
          def initialize(options)
            options = {
              record_class: ::ProtectedRecord::ChangeLog::Record
            }.merge!(options) if !options.has_key?(:record_class)

            load_options(:record_class, :user, :changed_object, options) and validate_state
          end

          def execute!
            create_change_log_record if @errors.empty?

            if @errors.empty? && @record.save
              return UseCase::Result.new(data: { change_log_record: @record })
            else
              return UseCase::Result.new(data: { change_log_record: @record }, errors: @errors)
            end
          end

          private
          def create_change_log_record
            @record                   = @record_class.new
            @record.user              = @user
            @record.recordable        = @changed_object
            @record.observed_changes  = ActiveSupport::JSON.encode(@changed_object.previous_changes)
          end

          protected
          def validate_state
            # What are we doing here, if not logging a change that has already happened?
            if !@changed_object.previous_changes.present?
              @errors << ActiveRecord::ActiveRecordError.new(':changed_object has no previous_changes')
            end
          end
        end
      end
    end
  end
end
