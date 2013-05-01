require "minitest_helper"

describe ProtectedRecord::UseCase::ChangeRequest::Create do
  describe "new" do
    before do
      @subject = ProtectedRecord::UseCase::ChangeRequest::Create

      @protected_record = TestCase.new(knowledge: "power", power: "money")
      @protected_record.save

      @mock_change_request_record_class = MiniTest::Mock.new
      @mock_change_request_record       = MiniTest::Mock.new
      @mock_user                        = MiniTest::Mock.new
      @mock_change_request_record_class.expect(:new, @mock_change_request_record)
      @mock_change_request_record.expect(:user=, @mock_user, [@mock_user])
      @mock_change_request_record.expect(:recordable=, @protected_record, [@protected_record])
      @mock_change_request_record.expect(:save, true)

      @protected_record.power= "trivial knowledge"
      @changes = JSON.generate(@protected_record.changes)
      @mock_change_request_record.expect(:requested_changes=, @changes, [@changes])

      @dependencies = {
        protected_keys:   %w{ power },
        protected_record: @protected_record,
        record_class:     @mock_change_request_record_class,
        user:             @mock_user
      }
    end

    it "initializes with required options" do
      subject = @subject.new(@dependencies)

      subject.must_be_instance_of @subject
    end

    it "initializes when options with defaults are omitted" do
      subject = @subject.new(@dependencies.reject { |k| k == :record_class })

      subject.must_be_instance_of @subject
    end

    it "fails to initialize without :user" do
      begin
        @subject.new(@dependencies.reject { |k| k == :user })
      rescue => e
        e.must_be_kind_of RuntimeError
      end
    end

    it "fails to initialize without :changed_object" do
      begin
        @subject.new(@dependencies.reject { |k| k == :protected_record })
      rescue => e
        e.must_be_kind_of RuntimeError
      end
    end

    it "returns a result" do
      result = @subject.new(@dependencies).execute!

      result.must_be_kind_of(PayDirt::Result)
    end
    it "does the deed" do
      result = @subject.new(@dependencies).execute!

      @mock_change_request_record.verify

      result.successful?.must_equal true
    end

    it "can read protected_keys from your model" do
      so = @subject.new @dependencies.reject { |k| k.to_s == "protected_keys" }
      result = so.execute!


      @mock_change_request_record.verify

      result.successful?.must_equal true
    end

    it "it's not successful if #save fails" do
      @mock_change_request_record.save
      @mock_change_request_record.expect(:save, false)

      result = @subject.new(@dependencies).execute!

      @mock_change_request_record.verify

      result.successful?.must_equal false
    end
  end
end

