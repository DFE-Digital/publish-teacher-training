# Services

We are using the gem [dry-container][dry-container] to create containers for services to allow for
a single place that instantiates all the services related to a model

## Conventions

- Use the `execute` method as the interface on the service
- Use named arguments to call `execute` to explicitly state what the arguments going in are
- Services with logic related to a single instance of a model specifically are executed on the model
- Services related to multiple models or collections of a model are executed outside of the model (e.g. 
services for rollover)

## For models

**Creating new services**

- Create the service in the `/app/services/{model name}` directory
- Register the service in a method on the model called `services` using [dry-container][dry-container] e.g.

```ruby
def services
  return @services if @services.present?
  @services = Dry::Container.new
  @services.register(:service_name) { ExampleModel::ServiceName.new }
end
```

- Delegate to the service in the model

```ruby
def do_the_thing
  services[:service_name].execute(foo: "bar")
```

### Testing the service is delegated

To test that the model delegates to the service, you can use the following rspec matcher:

```ruby
it "delgates to the service" do
  expect(model).to(
    delegate_method_to_service(
      :do_the_thing,
      "ExampleModel::ServiceName",
    ).with_arguments(
      foo: "bar",
    ),
  )
end
```

## For services not on the model

- Create the service in the `app/services` directory in an appropriate name space
- Register the service in the `services_container.rb` class
- Call the service from the container class where required

[dry-container]: https://dry-rb.org/gems/dry-container/0.8/
