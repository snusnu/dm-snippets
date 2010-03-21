module Addressable
  include DataMapper::Resource
  is :remixable
  # ...
end

module Linkable
  include DataMapper::Resource
  is :remixable
  # ...
end

class Person
  include DataMapper::Resource
  property :id, Serial
  # ...
end

#
# Relate any module that is :remixable to the class on which this method is called.
#
# @param [Fixnum] cardinality
# @param [Symbol,String] relationship_name
# @param [Hash] options
# 
# @option options [Symbol,String,Model]      :remixable
# @option options [Symbol,String,Model]      :model
# @option options [Symbol,String,Model,Hash] :through
#
#
# @example 1:1 remixable with default naming conventions
#
#   Person.remix 1, :address, :model => 'PersonAddress', :remixable => :addressable
#
#   1) Defines the PersonAddress model and includes the Addressable module.
#   2) Establishes the following relationships on the participating models.
#
#   Person.has 1, :address, :model => 'PersonAddress', :target_key => [:person_id]
#   PersonAddress.belongs_to :person, 'Person'
#
#
# @example 1:1 remixable with explicit options
#
#   Person.remix 1, :address, :model => 'PersonAddress'
#     :remixable => [ :addressable, { :target_key => [:human_id] } ]
#
#   1) Defines the PersonAddress model and includes the Addressable module.
#   2) Establishes the following relationships on the participating models.
#
#   Person.has 1, :address, :model => 'PersonAddress', :target_key => [:human_id]
#   PersonAddress.belongs_to :human, 'Person'
#
#
# @example 1:m remixables with default naming conventions
#
#   Person.remix n, :addresses, :model => 'PersonAddress', :remixable => :addressable
#
#   1) Defines the PersonAddress model and includes the Addressable module.
#   2) Establishes the following relationships on the participating models.
#
#   Person.has n, :addresses, :model => 'PersonAddress', :target_key => [:person_id]
#   PersonAddress.belongs_to :person, 'Person'
#
#
# @example 1:m remixables with explicit options
#
#   Person.remix n, :addresses, :model => 'PersonAddress',
#     :remixable => [ :addressable, { :target_key => [:human_id] } ]
#
#   1) Defines the PersonAddress model and includes the Addressable module.
#   2) Establishes the following relationships on the participating models.
#
#   Person.has n, :addresses, :model => 'PersonAddress', :target_key => [:human_id]
#   PersonAddress.belongs_to :human, 'Person'
#
#
# @example m:m through remixable with default naming conventions
#
#   Person.remix n, :references, :model => 'Link', :through => :linkable
#
#   1) Defines the PersonReference model and includes the Linkable module.
#   2) Establishes the following relationships on the participating models.
#
#   PersonReference.belongs_to :person
#   PersonReference.belongs_to :link
#
#   Person.has n, :person_references, :model => 'PersonReference'
#   Link.  has n, :person_references, :model => 'PersonReference'
#
#   Person.has n, :references, :model => 'Link', :through => :person_references, :via => :link
#
#
# @example m:m through remixable with explicit options
#
#   Person.remix n, :references, :model => 'Link',
#     :through => [ :linkable,  {
#         :as => :person_links,            # defaults to :person_references
#         :model => 'PersonReferenceLink', # defaults to 'PersonReference'
#         :source_key => [:human_id],      # defaults to :person_id
#         :target_key => [:reference_id]   # defaults to :link_id
#       }
#     ]
#
#   1) Defines the PersonReference model and includes the Linkable module.
#   2) Establishes the following relationships on the participating models.
#
#   PersonReferenceLink.belongs_to :human, 'Person'
#   PersonReferenceLink.belongs_to :reference, 'Link'
#
#   Person.has n, :person_links, :model => 'PersonReferenceLink', :target_key => [:human_id]
#   Link.  has n, :person_links, :model => 'PersonReferenceLink', :target_key => [:reference_id]
#
#   Person.has n, :references, :model => 'Link', :through => :person_references, :via => :reference
#
#
# @example self referential m:m through remixable
#
#   Person.remix n, :friends, :model => 'Person',
#     :through => [ :social_contact,  {
#         :as => :friendships,              # defaults to :person_references
#         :model => 'Friendship',           # defaults to 'PersonReference'
#         :source_key => [:person_id],      # defaults to :person_id
#         :target_key => [:other_person_id] # defaults to :person_id
#       }
#     ]
#
#   1) Defines the PersonReference model and includes the Linkable module.
#   2) Establishes the following relationships on the participating models.
#
#   Friendship.belongs_to :person,       'Person'
#   Friendship.belongs_to :other_person, 'Person'
#
#   Person.has n, :friendships, :model => 'Friendship', :target_key => [:person_id]
#   Link.  has n, :friendships, :model => 'Friendship', :target_key => [:other_person_id]
#
#   Person.has n, :friends, :model => 'Person', :through => :friendships, :via => :other_person
#
def is_remixable(cardinality, relationship_name, options)
  # TODO implement
end
