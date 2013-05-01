module ProtectedRecord
  module UseCase
    module ChangeFilter
      class Create
        include PayDirt::UseCase
        def initialize(options)
          load_options(:protected_record, options)
          validate_state
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

        protected
        def validate_state
          if !@protected_keys.kind_of?(Array)
            if @protected_record.respond_to? :protected_keys
              @protected_keys = @protected_record.protected_keys
            else
              @protected_keys = []
            end
          end
        end
      end
    end
  end
end
