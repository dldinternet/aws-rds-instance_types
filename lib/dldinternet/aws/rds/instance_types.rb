module DLDInternet
  module AWS
    module RDS
      module Instance_Types

        class << self

          require 'dldinternet/aws/rds/instance_types/mixins/rds_instance_types'
          include DLDInternet::AWS::RDS::Instance_Types::MixIns::RDS_Instance_Types

        end

      end

    end

  end

end
