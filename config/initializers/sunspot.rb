class OhmInstanceAdapter < Sunspot::Adapters::InstanceAdapter
  def id
    @instance.id
  end
end

class OhmDataAccessor < Sunspot::Adapters::DataAccessor
  def load(id)
    @clazz[id]
  end
end

Sunspot::Adapters::InstanceAdapter.register(OhmInstanceAdapter, Ohm::Model)
Sunspot::Adapters::DataAccessor.register(OhmDataAccessor, Ohm::Model)
