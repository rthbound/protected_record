module ProtectedRecord
  module UseCase
    class Update
      include PayDirt::UseCase
      def initialize(options)
        # Defaults
        options = {
          change_request: UseCase::ChangeRequest::Create,
          change_filter:  UseCase::ChangeFilter::Create,
          change_log:     UseCase::ChangeLog::Create,
          change_request_record_class: ::ProtectedRecord::ChangeRequest::Record,
          change_log_record_class: ::ProtectedRecord::ChangeLog::Record
        }.merge!(options)

        load_options(:params, :protected_record, :change_request, :change_log, :change_filter, :user, options)
        validate_state
      end

      def execute!
        form_change_request

        # We are successful if all changes have been applied
        if !@protected_record.changes.present?
          return PayDirt::Result.new({
            data:    {
              updated: @protected_record,
              change_request: @change_request_record
            },
            success:   true
          })
        else
          return PayDirt::Result.new({
            data:    { failed: @protected_record.changes },
            success:   false
          })
        end
      end

      private
      def form_change_request
        @protected_record.attributes = @params

        request_result = @change_request.new({
          record_class:     @change_request_record_class,
          protected_keys:   @protected_keys,
          protected_record: @protected_record,
          user:             @user
        }).execute!

        if request_result.successful?
          @change_request_record = request_result.data[:change_request_record]
          revert_protected_attributes
          save_protected_record
        end
      end

      def save_protected_record
        @protected_record.save
        log_changes
      end

      def revert_protected_attributes
        revert_result = @change_filter.new({
          protected_keys: @protected_keys,
          protected_record: @protected_record
        }).execute!

        revert_result.successful? ? return : raise
      end

      def log_changes
        log_result = @change_log.new({
          user: @user,
          changed_object: @protected_record,
          record_class: @change_log_record_class
        }).execute!

        log_result.successful? ? return : raise
      end

      protected
      def validate_state
        # We expect some keys
        if !@protected_keys.kind_of?(Array)
          if @protected_record.respond_to? :protected_keys
            @protected_keys = @protected_record.protected_keys
          else
            @protected_keys = []
          end
        end

        # The keys should respond to to_s
        if @protected_keys.any? {|el| !el.respond_to?("to_s") }
          raise TypeError.new('All :protected_keys should respond to #to_s')
        end

        # The dirty_object should respond to all keys (as methods)
        @protected_keys.each do |key|
          error = ActiveRecord::ActiveRecordError.new(":dirty_object must respond to #{key.to_s}")
          raise error unless @protected_record.respond_to?(key.to_s)
        end
      end
    end
  end
end
