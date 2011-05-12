#!/usr/bin/env ruby

$LOAD_PATH << File.join('src', 'main', 'ruby')

require 'jenkins'
require 'fileutils'

class BuildMonitor

  def initialize(jenkinsList, targetFile)
    @jenkinsList = jenkinsList
    b = binding
    template = ERB.new(File.read('src/main/ruby/template.erb'))
    File.new(targetFile, 'w').puts template.result(b)
  end

end

if __FILE__ == $0
  urls = [
    'http://jenkins:8080/job/job1',
    'http://jenkins:8080/job/job2'
  ]

  builds = urls.map do |url|
    Jenkins.new url
  end

  FileUtils.mkdir_p('target')
  BuildMonitor.new(builds, "target/monitor.html")

  FileUtils.cp('src/main/web/building-green.gif', 'target')
  FileUtils.cp('src/main/web/building-blue.gif', 'target')
  FileUtils.cp('src/main/web/building-red.gif', 'target')
  FileUtils.cp('src/main/web/index.html', 'target')
end
