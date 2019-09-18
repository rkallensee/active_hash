module ActiveFile

  class Base < ActiveHash::Base
    extend ActiveFile::MultipleFiles

    class_attribute :filename, :root_path, :data_loaded, instance_reader: false, instance_writer: false

    @@instance_lock = Mutex.new

    class << self

      def delete_all
        @@instance_lock.synchronize do
          self.data_loaded = true
          super
        end
      end

      def reload(force = false)
        @@instance_lock.synchronize do
          return if !self.dirty && !force && self.data_loaded
          self.data = load_file
          self.data_loaded = true
          mark_clean
        end
      end

      def set_filename(name)
        @@instance_lock.synchronize do
          self.filename = name
        end
      end

      def set_root_path(path)
        @@instance_lock.synchronize do
          self.root_path = path
        end
      end

      def load_file
        raise "Override Me"
      end

      def full_path
        actual_filename  = filename   || name.tableize
        File.join(actual_root_path, "#{actual_filename}.#{extension}")
      end

      def extension
        raise "Override Me"
      end
      protected :extension

      def actual_root_path
        root_path  || Dir.pwd
      end
      protected :actual_root_path

      [:find, :find_by_id, :all, :where, :method_missing].each do |method|
        define_method(method) do |*args|
          reload unless data_loaded
          return super(*args)
        end
      end

    end
  end

end
