module ProtectedRecord
  module DirtyModel
    def self.included(base)
      base.extend(ClassMethods)

      def protected_keys
        self.class.send(:protected_keys)
      end
    end

    module ClassMethods
      def protected_keys(*args)
        @@protected_keys ||= args.to_a
      end
    end
  end
end
