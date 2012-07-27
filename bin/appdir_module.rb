#!/usr/bin/env ruby

require 'pp'
require 'erb'
require 'pathname'
require 'puppet'
require 'puppet/face'

def opts
  opts_parser = OptionParser.new do |opts|
    opts.banner = "Usage: appdir_module [options] [class_name]"
    opts.separator ""
    opts.separator "Options:"

    @options = Hash.new
    @options[:namespace] = 'puppetlabs'
    opts.on('-v', '--verbose', 'Enable verbose output.')                            { @options[:verbose]   = true }
    opts.on('-a', '--analyze', 'Analyze module and provide class and define type.') { @options[:analyze]   = true }
    opts.on('-n', '--namespace', 'The module user namespace on Forge.')             { |val| @options[:namespace] = val }

    #opts.on_tail('-h', '--help', 'This help message.') { display_help; @exit_code=129; exit(@exit_code) }
  end
end

def parse_options!
  @args = opts.order!(@args)
end

def parse_module!
  raise Exception, 'missing Puppet class name' if @args.empty?
  @class_name = @args.shift
  @module_name = @class_name.split('::').first
end

def find(name, type=nil, modulepath=nil)
  type ||= :hostclass
  Puppet[:modulepath] = modulepath if modulepath
  Puppet::Face[:resource_type,:current].search('*').find_all{ |x| x.type==type and x.name == name }
end

def type
  Puppet::Face[:resource_type,:current].search('*').find_all { |x| x.type==:hostclass }.collect{|x| {x.name => x.arguments.keys}}
end

def bash_script
  template = File.open(File.join(Pathname.new(__FILE__).dirname.expand_path.to_s, 'appdirector.erb'))
  ERB.new(template.read).result(binding)
end

@args = ARGV.dup
parse_options!
parse_module!
result = find(@class_name).collect{|x| {x.name => x.arguments.keys}}.first
@puppet_class = Hash.new
@puppet_class[:name] = @class_name
@puppet_class[:param] = result[@class_name]
puts bash_script
