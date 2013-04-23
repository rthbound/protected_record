module ProtectedRecord
  module UseCase
    module ChangeFilter
      class Create < PayDirt::Base
        def initialize(options)
          load_options(:protected_keys, :protected_record, options) and validate_state
        end

        def execute!
          revert_protected_attrs

          return PayDirt::Result.new(data: { change_request_record: @protected_record })
        end

        private
        def revert_protected_attrs
          @protected_keys.each do |key|
            if @protected_record.send("#{key.to_s}_changed?")
              @protected_record.send("#{key.to_s}=", @protected_record.send("#{key.to_s}_was"))
            end
          end
        end

        protected
        def validate_state
          # If there are no changes, there's no need to do any filtering
          if !@protected_record.changes.present?
            raise ActiveRecord::ActiveRecordError.new(':protected_record not dirty')
          end
        end
      end
    end
  end
end
