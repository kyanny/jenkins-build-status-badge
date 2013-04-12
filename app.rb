# -*- coding: utf-8 -*-
require 'sinatra'
require 'slim'
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'pathname'

helpers do
  def normalize_url_slashes(uri)
    uri.path = uri.path.gsub(%r!//!, '/')
    uri
  end

  def badge_url
    request.url.sub(/\/preview\?/, '/badge?')
  end

  def badge_html
    %Q!<img src="%s" title="Build Status" alt="Build Status" />! % [badge_url]
  end

  def badge_markdown
    "![Build Status](%s)]" % [badge_url]
  end
end

get '/' do
  slim :index
end

get '/preview' do
  slim :preview
end

get '/badge' do
  job_uri = normalize_url_slashes(URI(URI.decode(params['job_url'] + '/api/xml')))
  doc = Nokogiri(open(job_uri).read)
  build_uri = normalize_url_slashes(URI(doc.search('//build/url').first.children.first.text + '/api/xml'))
  doc = Nokogiri(open(build_uri).read)
  status = doc.search('//result').children.first.text
  redirect "/#{status.downcase}.png"
end
