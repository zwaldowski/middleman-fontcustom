require 'fontcustom'

module Middleman
  class FontcustomExtension < Extension
    option :font_name, 'fontcustom', 'Output font name'
    option :source_dir, 'assets/fontcustom', 'Folder contains icon files'
    option :fonts_dir, 'source/fonts', 'Folder to output fonts'
    option :css_dir, 'source/stylesheets', 'Folder to output css'
    option :templates, 'scss', 'Output templates'
    option :no_hash, true, 'Create hash for no cache policy'
    option :preprocessor_path, nil, 'Relative path from your compiled CSS to your output directory'
    option :autowidth, false, 'Trims horizontal white space from each glyph.'
    option :template_dirs, {}, 'Folders to redirect the output of custom templates'

    def initialize(app, options_hash={}, &block)
      super

      return unless app.environment == :development

      options_hash = options.to_h

      compile = ->(config){
        ::Fontcustom::Base.new({
          :font_name => config[:font_name],
          :input => config[:source_dir],
          :output => {
            :fonts => config[:fonts_dir],
            :css => config[:css_dir],
          }.merge(config[:template_dirs]),
          :templates => config[:templates].split(/\s/),
          :no_hash => config[:no_hash],
          :preprocessor_path => config[:preprocessor_path],
          :autowidth => config[:autowidth]
        }).compile
      }

      app.ready do

        files.changed do |file|
          next if files.send(:ignored?, file)
          next if options_hash[:source_dir] != File.dirname(file)

          begin
            compile.call(options_hash)
          rescue => e
            logger.info e.message
          end
        end

        files.deleted do |file|
          next if files.send(:ignored?, file)
          next if options_hash[:source_dir] != File.dirname(file)

          begin
            compile.call(options_hash)
          rescue => e
            logger.info e.message
          end
        end

      end
    end
  end
end
