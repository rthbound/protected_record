require "json"

module ProtectedRecord
  module UseCase
    module ChangeLog
      class Create
        include PayDirt::UseCase
        def initialize(options)
          options = {
            record_class: ::ProtectedRecord::ChangeLog::Record
          }.merge!(options) if !options.has_key?(:record_class)

          load_options(:record_class, :user, :changed_object, options)
        end

        def execute!
          if !@changed_object.previous_changes.present?
            return PayDirt::Result.new(data: { change_log_record: @record }, success: true)
          end
          initialize_change_log_record

          if @record.save
            return PayDirt::Result.new(data: { change_log_record: @record }, success: true)
          else
            return PayDirt::Result.new(data: { change_log_record: @record }, success: false)
          end
        end

        private
        def initialize_change_log_record
          @record                   = @record_class.new
          @record.user              = @user
          @record.recordable        = @changed_object
          @record.observed_changes  = JSON.generate(@changed_object.previous_changes)
        end
      end
    end
  end
end
