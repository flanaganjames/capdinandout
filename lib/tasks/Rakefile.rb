require 'rubygems'
require 'bundler/setup'
require 'releasy'
require 'tk'
require "rexml/document"
include REXML
require 'pp'
require "stringio"

Releasy::Project.new do
    name 'CAPDIandO'
    version '1.0'
    executable 'bin/CAPDIandO.rb'
    files 'CAPDIandO.rb'
    #exclude encoding
    
    add_build :osx_app do
        url 'com.github.flanaganjames.capdinandout'
        wrapper 'wrappers/gosu-mac-wrapper-0.7.47.tar.gz'
        icon 'media/Gosu.icns'
        add_package :tar_gz
    end
    
    add_deploy :local
end


