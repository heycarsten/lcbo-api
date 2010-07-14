module FieldTracking

  def self.included(doc)
    doc.send(:attr_accessor, :active_crawl)
    doc.send(:before_save, :set_tracked_changes)
    doc.send(:before_save, :set_crawl_timestamp)
    doc.send(:embeds_many, :changes, :class_name => "#{doc}Change")
    doc.send(:instance_variable_set, :@tracked_fields, [])
    doc.send(:instance_variable_set, :@change_class, :"#{doc}Change")
    doc.send(:scope, :active, :where => { :is_active => true })
    doc.send(:scope, :inactive, :where => { :is_active => false })
    doc.extend(ClassMethods)
  end

  module ClassMethods
    def change_class
      const_get(@change_class)
    end

    def tracked_fields(*fields)
      fields.empty? ? @tracked_fields : @tracked_fields.concat(fields)
    end

    def activate!
      return unless (crawl = Crawl.active.first)
      where(:crawl_timestamp.ne => crawl.timestamp).each do |doc|
        doc.update_attributes(:is_active => false)
      end
    end
  end

  protected

  def set_crawl_timestamp
    self.crawl_timestamp = self.active_crawl.timestamp
  end

  def set_tracked_changes
    if tracked_fields_changed?
      self.changes << self.class.change_class.new(tracked_field_changes)
    end
  end

  def tracked_fields_changed?
    self.crawl_timestamp != self.active_crawl.timestamp && tracked_fields_changed.any?
  end

  def tracked_fields_changed
    if persisted?
      changed.select { |field| self.class.tracked_fields.include?(field) }
    else
      self.class.tracked_fields
    end
  end

  def tracked_field_changes
    tracked_fields_changed.reduce(:crawl => self.active_crawl) do |hsh, key|
      hsh.merge(key => read_attribute(key.to_s))
    end
  end

end
