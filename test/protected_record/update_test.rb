require "minitest_helper"
require "active_record"

describe ProtectedRecord::UseCase::Update do
  before do
    @subject = ProtectedRecord::UseCase::Update

    @params = { params: {
      knowledge: "bad",
      power:     "money"
    }}

    @test_case = TestCase.new( knowledge: :power )

    @dependencies = {
      user:              MiniTest::Mock.new,
      protected_record: @test_case,
      protected_keys:   [:knowledge],
    }
    @dependencies.merge! @params
  end

  it "can be initialized" do
    @subject.must_respond_to :new
  end

  it "fails without required dependencies" do
    %w{ user params protected_record protected_keys }.each do |dep|
      begin
        @subject.new @dependencies.reject { |k| k.to_s == dep }
      rescue => e
        e.must_be_kind_of RuntimeError
      end
    end
  end

  it "can be executed" do
    @subject.new(@dependencies).must_respond_to :execute!
  end
end
