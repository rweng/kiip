require 'yaml'
require 'active_support/core_ext/hash/keys'

module Kiip
  class Castle
    class Config
      attr_reader :config, :castle, :tasks

      def initialize castle
        @castle = castle
        @tasks = {}
      end

      def path
        File.join(castle.path, 'config.yml')
      end

      def exists?
        File.exists? path
      end

      def save!
        File.open(path, 'w') { |f| f.write file_content.to_yaml }
      end

      def file_content
        tasks_hash = @tasks.inject({}) do |result, ary|
          task_name = ary.first
          task = ary.last.to_h
          task.delete :name

          if task[:target] == File.join(castle.home_path, task_name)
            task.delete :target
          else
            binding.pry
          end

          result[task_name] = task.stringify_keys
          result
        end

        {
            'tasks' => tasks_hash
        }
      end
    end
  end
end