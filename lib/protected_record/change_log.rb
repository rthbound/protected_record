module ProtectedRecord
  module ChangeLog
    class Record < ActiveRecord::Base
      self.table_name = "protected_record_change_log_records"
      attr_accessible :recordable, :user
      belongs_to :recordable, polymorphic: true
      belongs_to :user, class_name: "User", foreign_key: :user_id
    end

    # Include this module in models inheriting from AR::Base
    module Changer
      def self.included(base)
        # Include this in AR models only
        return unless base.ancestors.include?(ActiveRecord::Base)

        base.has_many :change_log_records, class_name: "ProtectedRecord::ChangeLog::Record"
      end
    end

    # Include this module in models inheriting from AR::Base
    module Changeling
      def self.included(base)
        # Include this in AR models only
        return unless base.ancestors.include?(ActiveRecord::Base)

        base.has_many :change_log_records, as: :recordable, class_name: "ProtectedRecord::ChangeLog::Record"
      end
    end
  end
end
