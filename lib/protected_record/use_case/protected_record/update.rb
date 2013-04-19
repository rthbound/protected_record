module UseCase
  module ProtectedRecord
    class Update < ::UseCase::Base
      def initialize(options)
        # Defaults
        options = {
          change_request_use_case: UseCase::ProtectedRecord::ChangeRequest::Create,
          change_log_use_case:     UseCase::ProtectedRecord::ChangeLog::Create
        }.merge!(options) if !options.has_key?(:record_class)

        load_options(:params, :protected_record, :change_request_use_case, :change_log_use_case, :protected_keys, :user, options)
        validate_state
      end

      def execute!
        form_change_request

        if @errors.empty? && !@protected_record.changes.present?
          return UseCase::Result.new(data: { params: @protected_record })
        else
          return UseCase::Result.new(data: { params: @protected_record }, errors: @errors)
        end
      end

      private
      def form_change_request
        @protected_record.attributes = @params

        unless @protected_record.id_was.nil?
          request_result = @change_request_use_case.new(protected_keys: @protected_keys, dirty_object: @protected_record, user: @user).execute!
          if request_result.successful?
            revert_protected_attrs
            save_protected_record
          end
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

      def save_protected_record
        @protected_record.save
        log_changes
      end

      def log_changes
        log_result = @change_log_use_case.new(user: @user, changed_object: @protected_record).execute!
        return true if log_result.successful?
      end

      protected
      def validate_state
        # We expect some keys
        if !@protected_keys.kind_of?(Array)
          @errors << TypeError.new(':protected_keys not kind of Array')
        end

        # The keys should respond to to_s
        if @protected_keys.any? {|el| !el.respond_to?("to_s") }
          @errors << TypeError.new('All :protected_keys should respond to #to_s')
        end

        # The dirty_object should respond to all keys (as methods)
        @protected_keys.each do |key|
          error = ActiveRecord::ActiveRecordError.new(":dirty_object must respond to #{key.to_s}")
          @errors << error unless @dirty_object.respond_to(key.to_s)
        end
      end
    end
  end
end
