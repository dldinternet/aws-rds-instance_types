module DLDInternet
  module AWS
    module RDS
      module Instance_Types
        HEADINGS = [
            :Instance_Type,
            :vCPU,
            :Memory,
            :PIOPS_Optimized,
            :Network_Performance,
            :Generation,
        ]
        DEBUG = true
        class Scraper
          attr_reader :instance_types

          # ---------------------------------------------------------------------------------------------------------------
          def initialize
            @instance_types = {}
          end

          # ---------------------------------------------------------------------------------------------------------------
          def getInstanceTypes(options={})
            unless @instance_types.size > 0
              require 'mechanize'
              mechanize = options[:mechanize]
              unless mechanize
                mechanize = Mechanize.new
                mechanize.user_agent_alias = 'Mac Safari' # Pretend to use a Mac
              end
              url = options[:url] || 'http://aws.amazon.com/rds/details/'

              page = mechanize.get(url)

              require 'nokogiri'

              nk = Nokogiri::HTML(page.body)
              div = nk.css('div.page-content')
              # noinspection RubyAssignmentExpressionInConditionalInspection
              if div = find_div(div, %r'^<div\s+class="nine columns content-with-nav')
                # noinspection RubyAssignmentExpressionInConditionalInspection
                if div = find_div(div, %r'^<div\s+class="content parsys')
                  divs = div.css('div').to_a
                  itm = nil
                  idx = 0
                  divs.each do |d|
                    as = d.css('div div h2 a')
                    as.each do |a|
                      # puts "'#{a.text}'"
                      if a.text.match %r'\s*DB Instance Classes\s*'
                        itm = d
                        break
                      end
                    end
                    break if itm
                    idx += 1
                  end
                  if idx < divs.count
                    divs = divs[idx..-1]
                    table = nil
                    divs.each do |d|
                      table = d.css('div.aws-table table')
                      break if table
                    end

                    @instance_types = scrapeTable(HEADINGS, table) if table
                  end
                end
              end
            end
            @instance_types
          end

          def find_div(nk,regex)
            ret = nil
            divs = nk.search('div')
            if divs.count > 0
              nine = divs.select { |div| div.to_s.match regex }
              if nine.count >= 1
                nine = nine.shift
                ret = nine
              end
            end
            ret
          end

          # ---------------------------------------------------------------------------------------------------------------
          def scrapeTable(cHeadings,table)
            raise Error.new 'Cannot find instance type table' unless (table.is_a?(Nokogiri::XML::Element) or table.is_a?(Nokogiri::XML::NodeSet))
            rows = table.search('tr')[0..-1]
            head = rows.shift

            cols = head.search('td').collect { |td|
              text = td.text.to_s
              text = text.gsub(%r/(\r?\n)+/, ' ').strip
              CGI.unescapeHTML(text)
            }
            instance_types = {
                :headings => {},
                :details  => []
            }
            (0..cols.size-1).map { |i| instance_types[:headings][cHeadings[i]] = cols[i] }
            instance_types[:headings][cHeadings[-1]] = 'Generation'
            instance_set = nil
            rows.each do |row|

              cells = row.search('td').collect { |td|
                CGI.unescapeHTML(td.text.to_s.gsub(%r/(\r?\n)+/, ' ').strip)
              }
              if cells.count == 1 or (cells[1] == cells[2] and cells[2] == cells[4])
                instance_set = cells[0]
              else
                raise StandardError.new "This row does not have the same number of cells as the table header: #{row.text.to_s.strip}" unless cells.size == cols.size
                instance = {}
                (0..cells.size-1).map { |i| instance[cHeadings[i]] = cells[i] }
                instance[cHeadings[-1]] = instance_set
                instance_types[:details] << instance
              end
            end
            instance_types
          end

        end
      end
    end
  end
end