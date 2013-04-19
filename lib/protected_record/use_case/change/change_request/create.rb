module ProtectedRecord
  module UseCase
    module Change
      module ChangeRequest
        class Create < ::ProtectedRecord::UseCase::Base
          def initialize(options)
            options = {
              record_class: ::ProtectedRecord::ChangeRequest::Record
            }.merge!(options) if !options.has_key?(:record_class)

            load_options(:protected_keys, :record_class, :user, :dirty_object, options) and validate_state
          end

          def execute!
            return UseCase::Result.new(data: nil, success: true) if !requested_changes.present?

            create_change_request_record if @errors.empty?

            if @errors.empty? && @record.save
              return UseCase::Result.new(data: { change_request_record: @record })
            else
              return UseCase::Result.new(data: { change_request_record: @record }, errors: @errors)
            end
          end

          private
          def create_change_request_record
            @record                   = @record_class.new
            @record.user              = @user
            @record.recordable        = @dirty_object
            @record.requested_changes = ActiveSupport::JSON.encode(requested_changes)
          end

          def requested_changes
            @dirty_object.changes.select do |key|
              @protected_keys.map(&:to_s).include? key.to_s
            end
          end

          protected
          def validate_state
            # If there are no changes, there's no need to make a request
            if !@dirty_object.changes.present?
              @errors << ActiveRecord::ActiveRecordError.new(':dirty_object not dirty')
            end
          end
        end
      end
    end
  end
end
