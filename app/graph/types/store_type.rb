StoreType = GraphQL::ObjectType.define do
  name 'Store'
  description 'An LCBO retail store location'

  field :id,                           types.ID
  field :isDead,                       types.Boolean, property: :is_dead
  field :name,                         types.String
  field :kind,                         types.String
  field :addressLine1,                 types.String,  property: :address_line_1
  field :addressLine2,                 types.String,  property: :address_line_2
  field :city,                         types.String
  field :postalCode,                   types.String,  property: :postal_code
  field :telephone,                    types.String
  field :fax,                          types.String
  field :latitude,                     types.Float
  field :longitude,                    types.Float
  field :productsCount,                types.Int,     property: :products_count
  field :inventoryCount,               types.Int,     property: :inventory_count
  field :inventoryPriceInCents,        types.Int,     property: :inventory_price_in_cents
  field :inventoryVolumeInMilliliters, types.Int,     property: :inventory_volume_in_milliliters
  field :hasWheelchairAccessability,   types.Boolean, property: :has_wheelchair_accessability
  field :hasBilingualServices,         types.Boolean, property: :has_bilingual_services
  field :hasProductConsultant,         types.Boolean, property: :has_product_consultant
  field :hasTastingBar,                types.Boolean, property: :has_tasting_bar
  field :hasBeerColdRoom,              types.Boolean, property: :has_beer_cold_room
  field :hasSpecialOccasionPermits,    types.Boolean, property: :has_special_occasion_permits
  field :hasVintagesCorner,            types.Boolean, property: :has_vintages_corner
  field :hasParking,                   types.Boolean, property: :has_parking
  field :hasTransitAccess,             types.Boolean, property: :has_transit_access
  field :sundayOpen,                   types.Int,     property: :sunday_open
  field :sundayClose,                  types.Int,     property: :sunday_close
  field :mondayOpen,                   types.Int,     property: :monday_open
  field :mondayClose,                  types.Int,     property: :monday_close
  field :tuesdayOpen,                  types.Int,     property: :tuesday_open
  field :tuesdayClose,                 types.Int,     property: :tuesday_close
  field :wednesdayOpen,                types.Int,     property: :wednesday_open
  field :wednesdayClose,               types.Int,     property: :wednesday_close
  field :thursdayOpen,                 types.Int,     property: :thursday_open
  field :thursdayClose,                types.Int,     property: :thursday_close
  field :fridayOpen,                   types.Int,     property: :friday_open
  field :fridayClose,                  types.Int,     property: :friday_close
  field :saturdayOpen,                 types.Int,     property: :saturday_open
  field :saturdayClose,                types.Int,     property: :saturday_close
  field :updatedAt,                    types.String,  property: :updated_at
  field :createdAt,                    types.String,  property: :created_at
end