module ProtectedRecord
  module Record
    def self.included(base)
      base.send :include, ProtectedRecord::ChangeLog::Changer
      base.send :include, ProtectedRecord::ChangeRequest::Changer
    end
  end
end
