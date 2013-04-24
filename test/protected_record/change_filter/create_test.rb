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

      @subject = ProtectedRecord::UseCase::ChangeFilter::Create

      @protected_record = TestCase.new(knowledge: "power", power: "money")
      @protected_record.save
    end

    it "initializes with required options" do
      @protected_record.knowledge="growth"
      @protected_record.power="knowledge"

      @protected_keys = %w{ power }
      @subject.new(protected_record: @protected_record, protected_keys: @protected_keys)
    end

    it "fails to initialize without :protected_record" do
      begin
        @subject.new(protected_keys: @protected_keys)
      rescue => e
        e.must_be_kind_of RuntimeError
      end
    end

    it "fails to initialize without :protected_keys" do
      begin
        @subject.new(protected_record: @protected_record)
      rescue => e
        e.must_be_kind_of RuntimeError
      end
    end

    it "returns a result" do
      @protected_record.knowledge="growth"
      @protected_record.power="knowledge"

      @protected_keys = %w{ power }
      @subject.new({
        protected_record: @protected_record,
        protected_keys: @protected_keys
      }).execute!.must_be_kind_of(PayDirt::Result)
    end

    it "allows unprotected changes" do
      @protected_keys = %w{}

      @protected_record.knowledge="growth"
      @protected_record.power="knowledge"

      result = @subject.new({
        protected_record: @protected_record,
        protected_keys: @protected_keys
      }).execute!

      ret_obj = result.data[:change_request_record]

      ret_obj.knowledge.must_equal "growth"
      ret_obj.power.must_equal "knowledge"
    end

    it "filters all protected_keys" do
      @protected_record.knowledge="growth"
      @protected_record.power="knowledge"

      @protected_keys = %w{ power knowledge }
      result = @subject.new({
        protected_record: @protected_record,
        protected_keys: @protected_keys
      }).execute!

      ret_obj = result.data[:change_request_record]

      ret_obj.knowledge.must_equal "power"
      ret_obj.power.must_equal "money"
    end

    it "will allow unprotected changes while reverting protected changes" do
      @protected_record.knowledge="growth"
      @protected_record.power="knowledge"

      @protected_keys = %w{ power }
      result = @subject.new({
        protected_record: @protected_record,
        protected_keys: @protected_keys
      }).execute!

      ret_obj = result.data[:change_request_record]

      ret_obj.knowledge.must_equal "growth"
      ret_obj.power.must_equal "money"
    end
  end
end
