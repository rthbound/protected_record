# protected_record

## Setup for rails applications

I've created an engine to provide the necessary migrations as well as a (very)
basic interface for triaging `ProtectedRecord::ChangeRequest::Record` objects.
You are free to use this gem without the engine, but you'll need to
[grab these](https://github.com/rthbound/protected_record_manager/tree/master/db/migrate).

### Your models

Prepare your models.
There's **two types** of models at play here:

1. User (for now I expect a `User` class and `current_user` method
2. Your records .. these are the models you want to track

So, in your models add `require "protected_record"`

```ruby
# app/models/user.rb
include ProtectedRecord::User
# includes ProtectedRecord::ChangeRequest::Changer
#        & ProtectedRecord::ChangeLog::Changer
```

```ruby
# app/models/any.rb
include ProtectedRecord::Record
# includes ProtectedRecord::ChangeRequest::Changeling
#        & ProtectedRecord::ChangeLog::Changeling
```

#### Protected Keys

You have two options,

1. Inject the `:protected_keys` option when you execute the update (this will always take precedence)
2. Include in your record class `ProtectedRecord::DirtyModel` and define them there:

```ruby
class SomeRecord < ActiveRecord::Base
  include ProtectedRecord::DirtyModel
  protected_keys :do_not_resuscitate, :organ_donor
end
```

If you do not specify either option, ProtectedRecord will use an empty array.

## Usage

1. protected_record will prevent changes to attributes you specify as protected.
2. Any attempted change will be logged as a
   `ProtectedRecord::ChangeRequest::Record`.
3. If any changes are allowed through the filter, protected_record
   will create a `ProtectedRecord::ChangeLog::Record` to log who changed what,
   and for which record.
4. **Important**: ProtectedRecord is opt-in only. It does not change the
   behavior of any AR methods, nor does it place any callbacks in your models.
   In order to update with protection, use the following:

This user can change anything but `:do_not_resuscitate`and `:organ_donor`.
Rejected changes will create `ProtectedRecord::ChangeRequest::Record` objects.
Permitted changes will create `ProtectedRecord::ChangeLog::Record` objects.

```ruby
ready = ProtectedRecord::Update.new({
  user:             current_user,
  params:           record_params,
  protected_record: @record,
  protected_keys:   %w{ do_not_resuscitate organ_donor }
})

result = ready.execute!

result.successful? #=> true
```

and

```ruby
# Who changed what, and when
@user.change_log_records

# Who attempted to change what, and when
@user.change_request_records

# What changed, and when
@record.change_log_records

# What changes were attempted, and when
@record.change_request_records
```

## Contributing

Please do. There's plenty that could be done to round out both the interface
and the the feature set.

Issues and pull requests would be most appreciated.
