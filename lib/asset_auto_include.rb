module ActionView
  module Helpers
    module AssetTagHelper
      @@aai_delimiter  = '-'
      
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
        @to_include = []

        asset_dir = File.join(RAILS_ROOT, "public", options[:directory])
        template_asset_dir = File.join(RAILS_ROOT, "public", options[:template_directory])

        # auto asset
        auto_asset = File.join(asset_dir, "#{options[:auto_dir]}.#{options[:extension]}")
        template_auto_asset = File.join(template_asset_dir, "#{options[:auto_dir]}.#{options[:template_extension]}")
        if File.exist?(auto_asset) || File.exist?(template_auto_asset)
          @to_include << "#{options[:auto_dir]}.#{options[:extension]}"
        end

        controller_path = @controller.controller_path
        action_name = @controller.action_name
        action_asset = File.join(controller_path, action_name)

        # namespaces & shared assets
        parts = []
        part = controller_path
        while part != "." do
          parts << part
          part = File.dirname(part)
        end
        parts.reverse.each do |path|
          shared_asset = path
          shared_path = File.join(asset_dir, options[:auto_dir], "#{shared_asset}.#{options[:extension]}")
          template_shared_path = File.join(template_asset_dir, options[:auto_dir], "#{shared_asset}.#{options[:template_extension]}")

          if File.exist?(shared_path) || File.exist?(template_shared_path)
            @to_include << File.join(options[:auto_dir], "#{shared_asset}.#{options[:extension]}")
          end
        end

        # find action and shared action files 
        template_action_path = File.join(template_asset_dir, options[:auto_dir], controller_path)
        if File.directory?(template_action_path)
          Dir.new(template_action_path).each do |file|
            if File.extname(file) == ".#{options[:template_extension]}"
              file.split(@@aai_delimiter).collect do |part|
                @to_include << File.join(options[:auto_dir], controller_path, file) if File.basename(part, ".#{options[:template_extension]}") == action_name
              end
            end
          end
        end
        
        action_path = File.join(asset_dir, options[:auto_dir], controller_path)
        if File.directory?(action_path) && (action_path != template_action_path)
          Dir.new(action_path).each do |file|
            if File.extname(file) == ".#{options[:extension]}"
              file.split(@@aai_delimiter).collect do |part|
                @to_include << File.join(options[:auto_dir], controller_path, file) if File.basename(part, ".#{options[:extension]}") == action_name
              end
            end
          end
        end

        #add the manually added files and clear them out
        @to_include |= ManualAsset::assets asset_type
        
        "<!-- auto #{asset_type.to_s} -->\n#{
          @to_include.uniq.collect { |source|
            self.send(options[:method], source)
          }.join("\n")
        }\n<!-- /auto #{asset_type.to_s} -->"
      end
      
      def register_asset_auto_include(asset_name = "", asset_type = :both)
        ManualAsset::register(asset_name, asset_type)
      end
      
      def self.register_asset_auto_include(asset_name = "", asset_type = :both)
        ManualAsset::register(asset_name, asset_type)
      end

    private
    def register_manual(asset_name = "", asset_type = :both)
        if asset_name.empty?
          return nil
        end
        if asset_type == :both
          @@aai_manual[:javascript] << "#{asset_name}.#{@@aai_extension[:javascript]}"  
          @@aai_manual[:stylesheet] << "#{asset_name}.#{@@aai_extension[:stylesheet]}"  
        else
          begin
            @@aai_manual[asset_type] << "#{asset_name}.#{@@aai_extension[asset_type]}"
          rescue
            raise "#{asset_type} is not a valid asset type"
          end
        end
        return nil
    end

    end
  end
end
class ManualAsset
      @@aai_manual = {:javascript => [], :stylesheet => []}
      @@aai_extension = {:javascript => 'js', :stylesheet => 'css'}

  def self.assets(asset_type, reset=true)
    assets = @@aai_manual[asset_type]
    @@aai_manual[asset_type]=[] if reset
    return assets
  end
  def self.register(asset_name = "", asset_type = :both)
        if asset_name.empty?
          return nil
        end
        if asset_type == :both
          @@aai_manual[:javascript] << "#{asset_name}.#{@@aai_extension[:javascript]}"  
          @@aai_manual[:stylesheet] << "#{asset_name}.#{@@aai_extension[:stylesheet]}"  
        else
          begin
            @@aai_manual[asset_type] << "#{asset_name}.#{@@aai_extension[asset_type]}"
          rescue
            raise "#{asset_type} is not a valid asset type"
          end
        end
        return nil    
  end
end
