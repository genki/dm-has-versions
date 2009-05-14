module DataMapper
  module Has
    module Versions
      class RevertError < StandardError; end

      def has_versions(options = {})
        storage_name = Extlib::Inflection.tableize(name + "Version")

        ignores = [options[:ignore]].flatten.compact.map do |ignore|
          properties[ignore.to_s.intern]
        end

        class << self; self end.class_eval do
          define_method :const_missing do |name|
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

        if options[:revision] != false
          ignores << property(:revision, Integer, :unique_index => true)
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
          if result && !dirty_attributes.except(*ignores).empty?
            break result if pending_version_attributes.empty?
            attributes = self.attributes.merge(pending_version_attributes)
            original_key = "#{self.class.storage_name.singular}_id"
            attributes[original_key.intern] = self.id
            version, latest = self.version, self.latest?
            transaction do
              self.revert_to!(version) unless latest
              self.class::Version.create(attributes.except(:id))
            end
            self.pending_version_attributes.clear
            @version = nil
          end

          result
        end

        self.after :destroy do |result|
          self.versions.destroy! if result
          result
        end

        include DataMapper::Has::Versions::InstanceMethods
      end

      module InstanceMethods
        def self.included(base)
          base.class_eval do
            def revision=(revision)
              if target = versions.get(revision)
                copy(target)
                self.attribute_set :revision, revision
              end
              !!target
            end
          end
        end
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

        def latest?
          version == versions.size
        end

        def version
          @version ||= versions.size
        end

        def version=(version)
          if target = versions.first(:offset => version)
            copy(target)
            @version = version
          end
          !!target
        end

        def revisions
          versions.all(:order => [:id.asc]).map(&:id)
        end

        def revert_to!(version)
          self.version = version
          pending_version_attributes.clear
          raise RevertError unless save
          target_id = versions[version].id
          versions.all(:id.gte => target_id).destroy!
        end

        def revert_to(version)
          transaction{revert_to!(version)}
          true
        rescue RevertError
          false
        end

        def revert
          revert_to(version) or raise RevertError
        end

      private
        def copy(target)
          self.properties.each do |property|
            next if property.key?
            name = property.name
            self.attribute_set(name, target.attribute_get(name))
          end
        end
      end
    end
  end
end
