
require 'net/http'
require "rexml/document"
require 'erb'
include REXML

class Jenkins

  attr_accessor :buildName, :lastBuildStatus, :lastDuration, :building, :lastFailed, :lastSuccessful

  def initialize(url)
    mainXml = httpGet(url + '/api/xml/')
    lastSuccessfulXml = httpGet(url + '/lastSuccessfulBuild/api/xml/')
    lastFailedXml = httpGet(url + '/lastFailedBuild/api/xml/')

    @buildName, lastBuildNumber = parseBuildNameAndLastBuildNumber(mainXml)
    lastBuildXml = httpGet(url + '/' + lastBuildNumber + '/api/xml/')
    @building = parseBuilding(lastBuildXml)
    @lastSuccessful = parseBuild(lastSuccessfulXml)
    @lastFailed = parseBuild(lastFailedXml)

    if @lastSuccessful.timestamp > @lastFailed.timestamp
      @lastBuildStatus = 'success'
      @lastDuration = @lastSuccessful.duration
    else
      @lastBuildStatus = 'fail'
      @lastDuration = @lastFailed.duration
    end
  end

  def parseBuildNameAndLastBuildNumber(xml)
    doc = Document.new(xml)
    displayName = doc.root.elements['displayName'].text.strip
    lastBuildNumber = doc.root.elements['lastBuild'].elements['number'].text.strip
    return displayName, lastBuildNumber
  end

  def parseBuilding(xml)
    doc = Document.new(xml)
    doc.root.elements['building'].text.strip
  end

  def parseBuild(xml)
    doc = Document.new(xml)
    timestamp = doc.root.elements['timestamp'].text.strip
    duration = doc.root.elements['duration'].text.strip
    number = doc.root.elements['number'].text.strip
    HudsonBuild.new(timestamp, duration, number)
  end

  def httpGet(url)
    return Net::HTTP.get(URI.parse(url))
  end

end

class HudsonBuild

  attr_accessor :timestamp, :duration, :number

  def initialize(timestamp, duration, number)
    @timestamp = timestamp
    @duration = duration
    @number = number
  end

end

