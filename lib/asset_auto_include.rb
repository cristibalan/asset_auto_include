module ActionView
  module Helpers
    module AssetTagHelper
      def asset_auto_include_tags(asset_type = :javascript, options = {})
        default_options = {
          :auto_dir => "auto"
        }
        options = default_options.merge(options)
        case asset_type.to_s
          when "javascript"
            options[:method]    ||= "javascript_include_tag"
            options[:extension] ||= "js"
            options[:directory] ||= "javascripts"
            options[:template_extension] ||= options[:extension]
            options[:template_directory] ||= options[:directory]
          when "stylesheet"
            options[:method]    ||= "stylesheet_link_tag"
            options[:extension] ||= "css"
            options[:directory] ||= "stylesheets"
            options[:template_extension] ||= "sass"
            options[:template_directory] ||= File.join("stylesheets", "sass")
        end
        to_include = []

        asset_dir = File.join(RAILS_ROOT, "public", options[:directory])
        template_asset_dir = File.join(RAILS_ROOT, "public", options[:template_directory])

        auto_asset = File.join(asset_dir, "#{options[:auto_dir]}.#{options[:extension]}")
        template_auto_asset = File.join(template_asset_dir, "#{options[:auto_dir]}.#{options[:template_extension]}")
        if File.exist?(auto_asset) || File.exist?(template_auto_asset)
          to_include << "#{options[:auto_dir]}.#{options[:extension]}"
        end

        controller_path = controller.class.controller_path
        action_asset = File.join(controller_path, controller.action_name)
        shared_asset = controller_path

        shared_path = File.join(asset_dir, options[:auto_dir], "#{shared_asset}.#{options[:extension]}")
        template_shared_path = File.join(template_asset_dir, options[:auto_dir], "#{shared_asset}.#{options[:template_extension]}")
        if File.exist?(shared_path) || File.exist?(template_shared_path)
          to_include << File.join(options[:auto_dir], "#{shared_asset}.#{options[:extension]}")
        end

        action_path = File.join(asset_dir, options[:auto_dir], "#{action_asset}.#{options[:extension]}")
        template_action_path = File.join(template_asset_dir, options[:auto_dir], "#{action_asset}.#{options[:template_extension]}")
        if File.exist?(action_path) || File.exist?(template_action_path)
          to_include << File.join(options[:auto_dir], "#{action_asset}.#{options[:extension]}")
        end

        "<!-- auto #{asset_type.to_s} -->\n#{
          to_include.uniq.collect { |source|
            self.send(options[:method], source)
          }.join("\n")
        }\n<!-- /auto #{asset_type.to_s} -->"
      end
    end
  end
end
