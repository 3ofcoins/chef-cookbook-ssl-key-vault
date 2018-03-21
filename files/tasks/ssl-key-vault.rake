# frozen_string_literal: true

CERTIFICATE_DIR = 'config/certificates' unless defined? CERTIFICATE_DIR
# CERTIFICATE_SUBJ = nil
CERTIFICATE_JSON = FileList[File.join(CERTIFICATE_DIR, '*.key')].ext('json')

autoload :JSON, 'json'

rule '.json' => ['.key', '.crt'] do |t|
  basepath = File.join(File.dirname(t.name), File.basename(t.name, '.json'))
  inputs = Dir["#{basepath}.*"].reject { |path| path == t.name || path =~ /~$/ }
  puts "generating #{t.name} ..."
  output = inputs
             .map { |f| f[basepath.length + 1..-1] }
             .zip(inputs.map { |f| File.read(f) })
  File.write t.name, JSON[Hash[output]]
end

rule %r{^#{Regexp.escape(CERTIFICATE_DIR)}/[^/]+\.key} do |t|
  sh "openssl genrsa -out #{t} #{ENV['KEY_SIZE'] || 2048}"
end

rule '.csr' => '.key' do |t|
  domain = File.basename(t.name, '.csr').sub(/^star\./, '*.')
  raise 'Please set CERTIFICATE_SUBJ' unless defined? CERTIFICATE_SUBJ
  sh "openssl req -new -key #{t.source} -subj '#{CERTIFICATE_SUBJ}/CN=#{domain}' -out #{t}" # rubocop:disable Metrics/LineLength
end

namespace 'ssl-key-vault' do
  desc 'Generate JSON of SSL certificates for chef-vault'
  task json: CERTIFICATE_JSON

  desc 'Update certificates in chef-vault'
  task upload: CERTIFICATE_JSON do
    existing = JSON[`knife data bag show certs -F json`]
                 .reject { |id| id =~ /_keys$/ }
    CERTIFICATE_JSON.each do |json_path|
      basename = File.basename(json_path, '.json')
      next if ENV['CERT'] && ENV['CERT'] != basename
      basepath = File.join(File.dirname(json_path), basename)
      query = if File.exist?("#{basepath}.query")
                File.read("#{basepath}.query").strip
              else
                "ssl_certificates_#{basename}:true"
              end
      item = "ssl-key-#{basename.gsub(/[^a-z0-9]/, '_')}"
      op = existing.include?(item) ? 'update' : 'create'
      sh "knife vault #{op} certs #{item} --json #{json_path} --search '#{query}'" # rubocop:disable Metrics/LineLength
    end
  end
end
