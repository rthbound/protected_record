require "minitest_helper"

describe ProtectedRecord::Update do
  before do
    @subject = ProtectedRecord::Update

    @params = { params: {
      knowledge: "bad",
      power:     "money"
    }}

    @test_case = TestCase.new( knowledge: :power )

    @dependencies = {
      change_log_record_class: @change_log_record_class = MiniTest::Mock.new,
      change_request_record_class: @change_request_record_class = MiniTest::Mock.new,
      user:              @user = MiniTest::Mock.new,
      protected_record: @test_case,
      protected_keys:   [:knowledge],
    }
    @dependencies.merge! @params
  end

  it "can be initialized" do
    @subject.must_respond_to :new
  end

  it "fails without required dependencies" do
    %w{ user params protected_record }.each do |dep|
      begin
        @subject.new @dependencies.reject { |k| k.to_s == dep }
      rescue => e
        e.must_be_kind_of RuntimeError
      end
    end
  end

  it "initializes without :protected_keys" do
    so = @subject.new @dependencies.reject { |k| k.to_s == "protected_keys" }
    so.must_respond_to :execute!
  end

  it "can be executed" do
    @subject.new(@dependencies).must_respond_to :execute!
  end

  it "will be successful" do
    @change_log_record_class.expect(:new, @clr_instance = MiniTest::Mock.new, [])
    @change_request_record_class.expect(:new, @crr_instance = MiniTest::Mock.new, [])
    @clr_instance.expect(:user=, @user, [@user])
    @clr_instance.expect(:recordable=, @user, [@test_case])
    @clr_instance.expect(:observed_changes=, "{\"knowledge\":[null,null]}", ["{\"knowledge\":[null,null]}"])
    @clr_instance.expect(:save, true)
    @crr_instance.expect(:user=, @user, [@user])
    @crr_instance.expect(:recordable=, @test_case, [@test_case])
    @crr_instance.expect(:requested_changes=, "{\"knowledge\":[null,\"power\"]}", ["{\"knowledge\":[null,\"power\"]}"])
    @crr_instance.expect(:save, true)
    assert @subject.new(@dependencies).execute!.successful?
  end
end
