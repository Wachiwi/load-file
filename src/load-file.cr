require "logger"
require "gitlab"
require "commander"
require "colorize"

require "./load-file/*"

module LoadFile
  #
  class LoadFile
    # 2. Configuration
    #      - Check configuration (only user-based)
    #      - Parse configuration
    #      - Validate configuration
    #      - Merge with defaults
    def init_config
      @log.debug("Loaded config")
    end

    # 3. Commandline arguments
    #      - Parse commandline args
    #      - Merge with configuration
    def init_cli(options, arguments)
      options.string["instance"] += '/' unless options.string["instance"].ends_with? '/'
      @gitlab = Gitlab.client "#{options.string["instance"]}api/v3", options.string["token"]
      @log.debug("Initialized cli")
    end

    # 4. Execute the query
    def query_file
      @log.debug("Created logger")
    end

    #      4.1 Get the right repository
    #          - Check if repository is accessible for user
    #          - If repos with the same name are available in multiple namespaces the user gets
    #          prompted to select one
    #          -
    def query_repository
      @log.debug("Created logger")
    end

    #      4.2 Get the file
    #          -
    def query_file_content
      @log.debug("Created logger")
    end

    # 5. Output the file contents to stdout
    def print_file
      @log.debug("Created logger")
    end

    def initialize(opts, args)
      @log = Logger.new(STDOUT)
      @log.progname = "load-file"
      @log.level = Logger::DEBUG
      self.init_config
      @log.info("Initialization finished")
      opts.string["instance"] += '/' unless opts.string["instance"].ends_with? '/'

      begin
        @gitlab = Gitlab.client "#{opts.string["instance"]}api/v3", opts.string["token"]
        if @gitlab.is_nil?
          puts "[Error] Could not connect to instance with token!"
          Process.exit 1
        else
          @log.debug("Initialized cli")
          projects = @gitlab.projects
          projects.each do |p|
            puts p.name_with_namespace
          end
        end
      rescue ex
        pp ex.message
      end
    end
  end
end

cli = Commander::Command.new do |cmd|
  cmd.use = "load-file"
  cmd.long = "Simple cli tool to load files from a customizable gitlab instance. (Intended use is for CI systems)"

  cmd.flags.add do |flag|
    flag.name = "instance"
    flag.short = "-i"
    flag.long = "--instance"
    flag.default = "https://gitlab.com"
    flag.description = "Specifies the URL of the gitlab instance."
  end

  cmd.flags.add do |flag|
    flag.name = "insecure"
    flag.short = "-k"
    flag.long = "--insecure"
    flag.default = false
    flag.description = "Specifies if self signed certificates should be ignored. (Currently no usage)"
  end

  cmd.flags.add do |flag|
    flag.name = "token"
    flag.short = "-t"
    flag.long = "--token"
    flag.default = ""
    flag.description = "Specifies the Access-Token that allows you access to the projects inside your gitlab instance."
  end

  cmd.flags.add do |flag|
    flag.name = "ref"
    flag.short = "-r"
    flag.long = "--ref"
    flag.default = "master"
    flag.description = "Specifies the Access-Token that allows you access to the projects inside your gitlab instance."
  end

  cmd.run do |options, arguments|
    if options.string["token"].empty?
      puts "  [ERROR] Token cannot be empty\n".colorize :red
      puts cmd.help
      Process.exit 1
    end

    if arguments.size != 2
      puts "  [ERROR] Wrong number of arguments (expected: 2, got: #{arguments.size})\n".colorize :red
      puts cmd.help
      Process.exit 1
    end
    lf = LoadFile::LoadFile.new options, arguments
  end
end

Commander.run(cli, ARGV)
