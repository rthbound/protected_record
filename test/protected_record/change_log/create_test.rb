require "minitest_helper"

describe ProtectedRecord::UseCase::ChangeLog::Create do
  describe "new" do
    before do
      @subject =   ProtectedRecord::UseCase::ChangeLog::Create
      @test_case = TestCase.new({
        knowledge: "power",
        power:     "money"
      })
      @test_case.save

      @change_log_record_class = MiniTest::Mock.new
      @change_log_record       = MiniTest::Mock.new
      @user                    = MiniTest::Mock.new
      @changes                 = JSON.generate(@test_case.previous_changes)
      @change_log_record_class.expect :new,         @change_log_record
      @change_log_record.expect       :user=,       @user, [@user]
      @change_log_record.expect       :recordable=, @test_case, [@test_case]
      @change_log_record.expect       :observed_changes=, @changes, [@changes]
      @change_log_record.expect       :save, true

      @dependencies = {
        user:           @user,
        record_class:   @change_log_record_class,
        changed_object: @test_case
      }
    end

    it "initializes with required options" do
      subject = @subject.new      @dependencies
      subject.must_be_instance_of @subject
    end

    it "initializes when options with defaults are omitted" do
      subject = @subject.new      @dependencies.reject { |k| k == :record_class }
      subject.must_be_instance_of @subject
    end

    it "fails to initialize without :user" do
      begin
        @subject.new @dependencies.reject { |k| k == :user }
      rescue => e
        e.must_be_kind_of RuntimeError
      end
    end

    it "fails to initialize without :changed_object" do
      begin
        @subject.new @dependencies.reject { |k| k == :changed_object }
      rescue => e
        e.must_be_kind_of RuntimeError
      end
    end

    it "returns a result" do
      result = @subject.new(@dependencies).execute!

      @change_log_record.verify

      result.must_be_kind_of(PayDirt::Result)
    end

    it "does the deed" do
      result = @subject.new(@dependencies).execute!

      @change_log_record.verify

      result.successful?.must_equal true
    end

    it "it's not successful if #save fails" do
      @change_log_record.save
      @change_log_record.expect(:save, false)

      result = @subject.new(@dependencies).execute!

      @change_log_record.verify

      result.successful?.must_equal false
    end
  end
end
