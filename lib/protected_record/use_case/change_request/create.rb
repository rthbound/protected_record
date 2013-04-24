module ProtectedRecord
  module UseCase
    module ChangeRequest
      class Create < PayDirt::Base
        def initialize(options)
          options = {
            record_class: ::ProtectedRecord::ChangeRequest::Record
          }.merge!(options) if !options.has_key?(:record_class)

          load_options(:protected_keys, :record_class, :user, :protected_record, options)
        end

        def execute!
          return PayDirt::Result.new(data: {}, success: true) if !requested_changes.present?

          initialize_change_request_record

          if @record.save
            return PayDirt::Result.new(data: { change_request_record: @record }, success: true)
          else
            return PayDirt::Result.new(data: { change_request_record: @record }, success: false)
          end
        end

        private
        def initialize_change_request_record
          @record                   = @record_class.new
          @record.user              = @user
          @record.recordable        = @protected_record
          @record.requested_changes = ActiveSupport::JSON.encode(requested_changes)
        end

        def requested_changes
          @protected_record.changes.select do |key|
            @protected_keys.map(&:to_s).include? key.to_s
          end
        end

        def revert_protected_attrs
          @protected_keys.each do |key|
            if @protected_record.send("#{key.to_s}_changed?")
              @protected_record.send("#{key.to_s}=", @protected_record.send("#{key.to_s}_was"))
            end
          end

          raise if @protected_keys.any? { |key| @protected_record.send("#{key}_changed?") }
        end
      end
    end
  end
end
