module DataMapper
  module Has
    module Versions
      def has_versions(options = {})
        ignores = [options[:ignore]].flatten.compact.map do |ignore|
          properties[ignore.to_s.intern]
        end

        class << self; self end.class_eval do
          define_method :const_missing do |name|
            storage_name = Extlib::Inflection.tableize(self.name + "Version")
            model = DataMapper::Model.new(storage_name)

            if name == :Version
              properties.each do |property|
                options = property.options
                model.property property.name, property.type, options
              end
              model.belongs_to self.storage_name.singular.intern

              self.const_set("Version", model)
            else
              super(name)
            end
          end
        end

        self.after_class_method :auto_migrate! do
          self::Version.auto_migrate!
        end

        self.after_class_method :auto_upgrade! do
          self::Version.auto_upgrade!
        end

        self.before :attribute_set do |property, value|
          pending_version_attributes[property] ||= self.attribute_get(property)
        end

        self.after :update do |result|
          if result && dirty_attributes.except(*ignores).present?
            return result if pending_version_attributes.empty?
            attributes = self.attributes.merge(pending_version_attributes)
            original_key = "#{self.class.storage_name.singular}_id"
            attributes[original_key.intern] = self.id
            self.class::Version.create(attributes.except(:id))
            self.pending_version_attributes.clear
          end

          result
        end

        include DataMapper::Has::Versions::InstanceMethods
      end

      module InstanceMethods
        ##
        # Returns a hash of original values to be stored in the
        # versions table when a new version is created. It is
        # cleared after a version model is created.
        #
        # --
        # @return <Hash>
        def pending_version_attributes
          @pending_version_attributes ||= {}
        end

        ##
        # Returns a collection of other versions of this resource.
        # The versions are related on the models keys, and ordered
        # by the version field.
        #
        # --
        # @return <Collection>
        def versions
          version = self.class.const_get("Version")
          original_key = "#{self.class.storage_name.singular}_id".intern
          version.all(original_key => self.id, :order => [:id.asc])
        end

        def version
          versions.size
        end

        def revert_to(version)
          if target = versions.first(:offset => version)
            transaction do
              self.properties.each do |property|
                next if property.key?
                name = property.name
                self.attribute_set(name, target.attribute_get(name))
              end
              pending_version_attributes.clear
              return false unless save
              versions.all(:id.gte => target.id).destroy!
            end
          end
          !!target
        end
      end
    end
  end
end
