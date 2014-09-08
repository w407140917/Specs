module Pod
  module Generator
    # Generates a prefix header file for a Pods library. The prefix header is
    # generated according to the platform of the target and the pods.
    #
    # According to the platform the prefix header imports `UIKit/UIKit.h` or
    # `Cocoa/Cocoa.h`.
    #
    class PrefixHeader < Header
      # @return [Array<FileAccessor>] The file accessors for which to generate
      #         the prefix header.
      #
      attr_reader :file_accessors

      # @param  [Array<FileAccessor>] file_accessors
      #         @see file_accessors
      #
      # @param  [Platform] platform
      #         @see platform
      #
      def initialize(file_accessors, platform)
        @file_accessors = file_accessors
        super platform
      end

      # Generates the contents of the prefix header according to the platform
      # and the pods.
      #
      # @note   Only unique prefix_header_contents are added to the prefix
      #         header.
      #
      # @return [String]
      #
      # @todo   Subspecs can specify prefix header information too.
      # @todo   Check to see if we have a similar duplication issue with
      #         file_accessor.prefix_header.
      #
      def generate
        result = super

        result << "\n"

        unique_prefix_header_contents = file_accessors.map do |file_accessor|
          file_accessor.spec_consumer.prefix_header_contents
        end.compact.uniq

        unique_prefix_header_contents.each do |prefix_header_contents|
          result << prefix_header_contents
          result << "\n"
        end

        file_accessors.each do |file_accessor|
          if prefix_header = file_accessor.prefix_header
            result << Pathname(prefix_header).read
          end
        end
        result
      end

      protected

      # Generates the contents of the header according to the platform.
      #
      # @return [String]
      #
      def generate_platform_import_header
        result =  "#ifdef __OBJC__\n"
        result << super
        result << "#endif\n"
      end
    end
  end
end
