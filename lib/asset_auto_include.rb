module ActionView
  module Helpers
    module AssetTagHelper
      def asset_auto_include_tags(asset_type = :javascript, extension = nil, directory = nil)
        extension = "js" if asset_type.to_s == "javascript"
        extension = "css" if asset_type.to_s == "stylesheet"
        directory ||= asset_type.to_s.pluralize
        controller_path = controller.class.controller_path

        asset_path = "#{RAILS_ROOT}/public/#{directory}/#{controller_path}"
        puts asset_path
        if File.directory? asset_path
          paths = ["_shared", controller.action_name]
          paths.collect { |source|
            puts File.join(asset_path, "#{source}")
            if File.exist?(File.join(asset_path, "#{source}.#{extension}"))
              puts "including..."
              self.send("#{asset_type}_include_tag", "#{controller_path}/#{source}.#{extension}")
            end
          }.join("\n")
        end
      end
    end
  end
end
