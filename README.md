# protected_record [![Gem Version](https://badge.fury.io/rb/protected_record.png)](http://badge.fury.io/rb/protected_record)[![Build Status](https://travis-ci.org/rthbound/protected_record.png?branch=master)](https://travis-ci.org/rthbound/protected_record)

## Setup for rails applications

I've created a gem called [protected_record_manager](https://github.com/rthbound/protected_record_manager)
to provide the necessary migrations as well as a (very) basic interface
for triaging `ProtectedRecord::ChangeRequest::Record` objects.
You are free to use this gem without the engine, but you'll need to
[grab these](https://github.com/rthbound/protected_record_manager/tree/master/db/migrate).

### Your models

Prepare your models.
There's **two types** of models at play here:

* User (for now I expect a `User` class)

```ruby
# app/models/user.rb
include ProtectedRecord::ResponsibleUser
# includes ProtectedRecord::ChangeRequest::Changer
#        & ProtectedRecord::ChangeLog::Changer
```
* Your records .. these are the models you want to track

```ruby
# app/models/some_record.rb
include ProtectedRecord::Record
# includes ProtectedRecord::ChangeRequest::Changeling
#        & ProtectedRecord::ChangeLog::Changeling
```

#### Protected Keys

You have three options,

1. Inject the `:protected_keys` option when you execute the update
(this will always take precedence over option 2).
2. Include in your record class `ProtectedRecord::DirtyModel`
and define protected_keys there

```ruby
# How to define :protected_keys in your models.
class SomeRecord < ActiveRecord::Base
  include ProtectedRecord::DirtyModel
  protected_keys :do_not_resuscitate, :organ_donor
end
```

Your third option is to omit `:protected_keys` entirely.
If they are not specified using either method, ProtectedRecord will use an empty array.

## Usage & Function

1. protected_record will prevent changes to attributes you specify as protected.
2. Any attempted change will be logged as a
   `ProtectedRecord::ChangeRequest::Record`.
3. If any changes are allowed through the filter, protected_record
   will create a `ProtectedRecord::ChangeLog::Record` to log who changed what,
   and for which record.
4. **Important!** ProtectedRecord is opt-in only. It does not change the
   behavior of any AR methods, nor does it place any callbacks in your models.
   In order to update with protection, use the following:

In the following example, the user will be allowed to change anything
except `:do_not_resuscitate`. Rejected changes will create
`ProtectedRecord::ChangeRequest::Record` objects. Permitted changes
will create `ProtectedRecord::ChangeLog::Record` objects.

```ruby
ready = ProtectedRecord::Update.new({
  user:             current_user,
  params:           record_params,
  protected_record: @record,
  protected_keys:   %w{ do_not_resuscitate }
})

result = ready.execute!

result.successful? #=> true
```

and

```ruby
# What changed
@user.change_log_records
@some_record.change_log_records

# What changes were attempted
@user.change_request_records
@some_record.change_request_records
```

## Contributing

Please do. There's plenty that could be done to round out both the interface
and the the feature set.

Issues and pull requests would be most appreciated.
