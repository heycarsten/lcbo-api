class Plan < ActiveRecord::Base
  enum kind: [
    :free,
    :supporter,
    :developer,
    :enterprise
  ]
end
