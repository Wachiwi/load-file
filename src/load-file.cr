require "logger"
require "gitlab"
require "cli"
require "colorize"

module LoadFile
  class LoadFile < Cli::Command
    version "0.1.0"

    @log = Logger.new(STDOUT)

    class Help
      header "load-file - Simple cli tool to load files from a customizable gitlab instance. (Intended use is for CI systems)"
    end

    class Options
      arg "project", desc: "project", required: true
      arg "file", desc: "file", required: true

      string %w(-i --instance), desc: "Specifies the URL of the gitlab instance.", default: "https://gitlab.com"
      bool %w(-k --insecure), desc: "Specifies if self signed certificates should be ignored. (Currently not used)", default: false
      string %w(-t --token), desc: "Specifies the Access-Token that allows you access to the projects inside your gitlab instance.", default: nil
      string %w(-r --ref), desc: "Specifies the Access-Token that allows you access to the projects inside your gitlab instance.", default: "master"
      help
    end

    def init_config
      @log.debug("Loaded config")
    end

    def run
      if options.token?.nil?
        print "[ERROR] Token cannot be empty".colorize :red
        Process.exit 1
      end

      # check_project_arg args.project
      # check_file_arg args.file
      if args.project.empty? || args.file.empty?
        print "[ERROR] project and file argument needs to be set".colorize :red
        Process.exit 1
      end

      #self.init_config

      if options.instance.ends_with? '/'
        instance = options.instance
      else
        instance = options.instance + '/'
      end

      gitlab = Gitlab.client "#{instance}api/v3", options.token

      if gitlab.nil?
        print "[Error] Could not connect to instance with token!"
        Process.exit 1
      end

      projects : (JSON::Any | Nil)
      project = nil

      begin
        projects = gitlab.projects
        if projects.nil?
          print "[Error] Could not find any projects".colorize :red
          Process.exit 1
        end
      rescue
        print "[Error] Could not connect to '#{instance}' with token".colorize :red
        Process.exit 1
      end

      projects.each do |proj|
        if proj["path_with_namespace"] == args.project
          project = proj
          break
        end
      end

      if project.nil?
        print "[Error] Could not find project named '#{args.project}'!".colorize :red
        Process.exit 1
      end

      begin
        file = gitlab.get("/projects/#{project["id"]}/repository/files/#{(URI.escape args.file).gsub '.', "%2E"}/raw?ref=#{options.ref}")

        print "#{file.body}"
        Process.exit 0
      rescue Gitlab::Error::NotFound
        print "[Error] Could not find the file '#{args.file}' at ref '#{options.ref}'".colorize :red
        Process.exit 1
      end
    end
  end
end

LoadFile::LoadFile.run ARGV
