require 'thor'
require 'awesome_print'
require 'colorize'
require 'dldinternet/aws/rds/instance_types'

module DLDInternet
  module AWS
    module RDS
      module Instance_Types
        # noinspection RubyParenthesesAfterMethodCallInspection
        class Cli < Thor
          class_option :verbose,      :type => :boolean
          class_option :debug,        :type => :boolean
          class_option :log_level,    :type => :string, :banner => 'Log level ([:trace, :debug, :info, :step, :warn, :error, :fatal, :todo])'
          class_option :inifile,      :type => :string
          class_option :help,         :type => :boolean
          class_option :format,       :type => :string, :default => 'pretty', :banner => '[:pretty, :yaml, :json]', :aliases => ['--output']

          no_commands do

            require 'dldinternet/aws/rds/instance_types/mixins/no_commands'
            include DLDInternet::AWS::RDS::Instance_Types::MixIns::NoCommands

          end

          def help()
            puts "Version: #{VERSION}"
            super
          end

          def self.start(argv = ARGV, config = {})
            if argv.size == 0 or argv[0].match(%r'^--')
              argv.unshift('get')
            end
            super(argv,config)
          end

          def initialize(args = [], local_options = {}, config = {})
            super(args,local_options,config)
            @log_level = :step
          end

          desc 'get', 'get instance types'
          def get()
            parse_options
            puts 'get instance types' if options[:verbose]

            it = DLDInternet::AWS::RDS::Instance_Types.get_rds_instance_types()
            case options[:format]
            when /yaml/
              puts it.to_yaml line_width: 1024, indentation: 4, canonical: false
            when /json/
              puts JSON.pretty_generate( it, { indent: "\t", space: ' '})
            else
              puts it.ai
            end
            0
          end

          desc 'load PATH', 'load instance types'
          def load(path)
            parse_options
            puts 'load instance types' if options[:verbose]

            it = DLDInternet::AWS::RDS::Instance_Types.load_rds_instance_types(path)
            ap it
          end

          desc 'save PATH', 'save instance types'
          def save(path)
            parse_options
            puts 'save instance types' if options[:verbose]

            it = DLDInternet::AWS::RDS::Instance_Types.get_rds_instance_types()
            DLDInternet::AWS::RDS::Instance_Types.save_rds_instance_types(path, it)
          end

          default_task 'get'
        end
      end
    end
  end
end
