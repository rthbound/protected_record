module ProtectedRecord
  module UseCase
    module ChangeFilter
      class Create < PayDirt::Base
        def initialize(options)
          load_options(:protected_keys, :protected_record, options)
        end

        def execute!
          if @protected_record.changes.present?
            revert_protected_attrs
          end

          return PayDirt::Result.new(data: { change_request_record: @protected_record }, success: true)
        end

        private
        def revert_protected_attrs
          @protected_keys.each do |key|
            if @protected_record.send("#{key.to_s}_changed?")
              @protected_record.send("#{key.to_s}=", @protected_record.send("#{key.to_s}_was"))
            end
          end
        end
      end
    end
  end
end
