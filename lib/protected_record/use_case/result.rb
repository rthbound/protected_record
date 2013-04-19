module ProtectedRecord
  module UseCase
    class Result
      # The response from a use case execution
      #
      # Every use case should return a Result after it runs.
      #
      # @param [options] options_hash
      # A hash specifying the appropriate options
      #
      # @return [UseCase::Result]
      # the Result instance
      #
      # @example
      # UseCase::Result.new(success: true, data: {})
      # # => <UseCase::Result>
      #
      # @api public
      def initialize(options)
        @success = options.fetch(:success) { !options[:errors].present? }
        @errors = options[:errors]
        @data = options[:data]
      end

      # @api public
      def successful?
        !!@success
      end

      def errors
        @errors
      end

      # @api public
      def data
        @data
      end
    end
  end
end
