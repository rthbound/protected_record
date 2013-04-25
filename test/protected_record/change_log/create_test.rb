require "minitest_helper"
require "active_record"

describe ProtectedRecord::UseCase::ChangeFilter::Create do
  describe "new" do
    before do
      class TestCase
        include ActiveModel::Dirty

        define_attribute_methods [:knowledge, :power]

        def knowledge
          @knowledge
        end

        def power
          @power
        end

        def knowledge=(val)
          knowledge_will_change! unless val == @knowledge
          @knowledge = val
        end

        def power=(val)
          power_will_change! unless val == @power
          @power = val
        end

        def save
          @previously_changed = changes
          @changed_attributes.clear
        end

        def initialize(attributes = {})
          attributes.each do |name, value|
            send("#{name}=", value)
          end
        end
        #####
      end

      @subject = ProtectedRecord::UseCase::ChangeLog::Create

      @protected_record = TestCase.new(knowledge: "power", power: "money")
      @protected_record.save

      @mock_change_log_record_class = MiniTest::Mock.new
      @mock_change_log_record = MiniTest::Mock.new
      @mock_user = MiniTest::Mock.new
      @changes = JSON.generate(@protected_record.previous_changes)
      @mock_change_log_record_class.expect(:new, @mock_change_log_record)
      @mock_change_log_record.expect(:user=, @mock_user, [@mock_user])
      @mock_change_log_record.expect(:recordable=, @protected_record, [@protected_record])
      @mock_change_log_record.expect(:observed_changes=, @changes, [@changes])
      @mock_change_log_record.expect(:save, true)

      @dependencies = {
        record_class: @mock_change_log_record_class,
        user: @mock_user,
        changed_object: @protected_record
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
        @subject.new(@dependencies.reject { |k| k == :changed_object })
      rescue => e
        e.must_be_kind_of RuntimeError
      end
    end

    it "returns a result" do
      result = @subject.new(@dependencies).execute!

      @mock_change_log_record.verify

      result.must_be_kind_of(PayDirt::Result)
    end

    it "does the deed" do
      result = @subject.new(@dependencies).execute!

      @mock_change_log_record.verify

      result.successful?.must_equal true
    end

    it "it's not successful if #save fails" do
      @mock_change_log_record.save
      @mock_change_log_record.expect(:save, false)

      result = @subject.new(@dependencies).execute!

      @mock_change_log_record.verify

      result.successful?.must_equal false
    end
  end
end
