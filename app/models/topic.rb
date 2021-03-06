class Topic < Section
  resourcify

  has_and_belongs_to_many :agencies,
        class_name: 'Agency',
        join_table: :section_connections,
        foreign_key: :section_id,
        association_foreign_key: :connection_id

  has_and_belongs_to_many :departments,
        class_name: 'Department',
        join_table: :section_connections,
        foreign_key: :section_id,
        association_foreign_key: :connection_id

  has_and_belongs_to_many :topics,
        class_name: 'Topic',
        join_table: :section_connections,
        foreign_key: :section_id,
        association_foreign_key: :connection_id

end
