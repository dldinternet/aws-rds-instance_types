require 'thor'
require 'awesome_print'
require 'inifile'
require 'colorize'
require 'dldinternet/aws/rds/instance_types/scraper'

module DLDInternet
  module AWS
    module RDS
      module Instance_Types
        module MixIns
          module RDS_Instance_Types

            def getFileFormat(path)
              format = case File.extname(File.basename(path)).downcase
                         when /json|js/
                           'json'
                         when /yaml|yml/
                           'yaml'
                         else
                           raise DLDInternet::AWS::RDS::Instance_Types::Error.new("Unsupported file type: #{path}")
                       end
            end

            def saveRDS_Instance_Types(path,it)
              format = getFileFormat(path)
              begin
                File.open path, File::CREAT|File::TRUNC|File::RDWR, 0644 do |f|
                  case format
                    when /yaml/
                      f.write it.to_yaml line_width: 1024, indentation: 4, canonical: false
                    when /json/
                      f.write JSON.pretty_generate(it, { indent: "\t", space: ' '})
                    else
                      f.write YAML::dump(it)
                      # abort! "Unsupported save format #{format}!"
                  end
                  f.close
                end
              rescue
                abort! "!!! Could not write file #{path}: \nException: #{$!}\nParent directory exists? #{File.directory?(File.dirname(path))}\n"
              end
              0
            end

            def loadRDS_Instance_Types(path)
              format = getFileFormat(path)
              spec = File.read(path)
              case format
                when /json/
                  JSON.parse(spec)
                #when /yaml/
                else
                  begin
                    YAML.load(spec)
                  rescue Psych::SyntaxError => e
                    abort! "Error in the template specification: #{e.message}\n#{spec.split(/\n/).map{|l| "#{i+=1}: #{l}"}.join("\n")}"
                  end
                # else
                #   abort! "Unsupported file type: #{path}"
              end
            end

            def getRDS_Instance_Types(mechanize=nil)
              unless mechanize
                require 'mechanize'
                mechanize = ::Mechanize.new
                mechanize.open_timeout = 5
                mechanize.read_timeout = 10
              end

              scraper = DLDInternet::AWS::RDS::Instance_Types::Scraper.new()

              begin
                return scraper.getInstanceTypes(:mechanize => mechanize)
              rescue Timeout::Error => e
                puts "Unable to retrieve instance type details in a reasonable time (#{mechanize.open_timeout}s). Giving up ...".light_red
                return nil
              end
            end

            def abort!(msg)
              raise DLDInternet::AWS::RDS::Instance_Types::Error.new msg
            end

          end
        end
      end
    end
  end
end