# protected_record
## Setup for rails applications
I've created an engine to provide the necessary migrations as well as a basic interface for triaging change requests.  You are free to use this gem without the engine, but you'll need to visit [protected_record_manager](https://github.com/rthbound/protected_record_manager/tree/master/db/migrate) and copy the migrations into your app manually.

Add to your Rails application's Gemfile:

    gem "protected_record_manager"
    
And to your Rails application's `routes.rb`:
```ruby
mount ProtectedRecordManager::Engine, :at => "/protected_record_manager", as: "protected_record_manager"
```
Which will provide a user interface for triaging change requests at:
```
http://localhost:3000/protected_record_manager/change_requests
```
**Important:** Only users with `@user.protected_record_manager == true` will be able to access these resources.

Now copy over and run the migrations:
```
$ rake protected_record_manager:install:migrations
$ rake db:migrate
```
Lastly, you'll need to prepare your models. There's two types of models at play here:

1. User (for now I expect a `User` class and `current_user` method
2. records .. these are the models you want to track

So in `user.rb`
```ruby
include ProtectedRecord::ChangeRequest::Changer
include ProtectedRecord::ChangeLog::Changer
```

And in any model where you want to use protection:
```ruby
include ProtectedRecord::ChangeRequest::Changeling
include ProtectedRecord::ChangeLog::Changeling
```
## Usage
1. protected_record will prevent changes to attributes you specify as protected.
2. Any attempted change will be logged as a `ProtectedRecord::ChangeRequest::Record`. 
3. If any changes are allowed through the filter, protected_record will create a `ProtectedRecord::ChangeLog::Record` to log who changed what, and for which record.
4. **Important**: ProtectedRecord is opt-in only. It does not change the way behavior of any AR methods, nor does it use any callbacks. In order to update with protection, use the following: 

```ruby
# UseCase module will filter changes to protected_keys,
# creating a "change request" rather than applying changes

# UseCase module will allow other changes to be applied,
# creating a "change log" entry for the observed changes

result = ProtectedRecord::UseCase::Update.new({
  params: record_params,
  protected_record: @record,
  user: current_user,
  protected_keys: %w{ do_not_resuscitate organ_donor }
}).execute!

result.successful? #=> true
```
and call methods like
```ruby
@user.change_log_records
@user.change_request_records
@record.change_log_records
@record.change_request_records
```
