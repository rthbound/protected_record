module ProtectedRecord
  module ChangeRequest
    class Record < ActiveRecord::Base
      self.table_name = "protected_record_change_request_records"
      attr_accessible :recordable, :user

      belongs_to :recordable, polymorphic: true
      belongs_to :user,       class_name: "User",
        foreign_key: :user_id
    end

    module Changer
      def self.included(base)
        # Include this in models only
        return unless base.ancestors.include?(ActiveRecord::Base)

        base.has_many :change_request_records, class_name: "ProtectedRecord::ChangeRequest::Record"
      end
    end

    module Changeling
      def self.included(base)
        # Include this in models only
        return unless base.ancestors.include?(ActiveRecord::Base)

        base.has_many :change_request_records, as: :recordable,
          class_name: "ProtectedRecord::ChangeRequest::Record"
      end
    end
  end
end
