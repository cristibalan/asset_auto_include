module ActionView
  module Helpers
    module AssetTagHelper
      def asset_auto_include_tags(asset_type = :javascript, options = {})
        default_options = {
          :extension => nil,
          :directory => nil,
          :method => nil
        }
        options = default_options.merge(options)
        case asset_type.to_s
          when "javascript"
            options[:extension] ||= "js"
            options[:directory] ||= asset_type.to_s.pluralize
            options[:method]    ||= "javascript_include_tag"
          when "stylesheet"
            options[:extension] ||= "css"
            options[:directory] ||= asset_type.to_s.pluralize
            options[:method]    ||= "stylesheet_link_tag"
        end

        controller_path = controller.class.controller_path

        asset_path = "#{RAILS_ROOT}/public/#{options[:directory]}/#{controller_path}"
        puts asset_path
        if File.directory? asset_path
          paths = ["_shared", controller.action_name]
          paths.collect { |source|
            puts File.join(asset_path, "#{source}")
            if File.exist?(File.join(asset_path, "#{source}.#{options[:extension]}"))
              puts "including..."
              self.send("#{options[:method]}", "#{controller_path}/#{source}.#{options[:extension]}")
            end
          }.join("\n")
        end
      end
    end
  end
end
