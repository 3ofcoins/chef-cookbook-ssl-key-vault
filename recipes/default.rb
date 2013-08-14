# Ssl Key Vault
# =============

chef_gem 'chef-vault'
require 'chef-vault'

directory '/etc/ssl/certs' do
  recursive true
  owner 'root'
  group 'root'
  mode '0755'
end

directory '/etc/ssl/private' do
  owner 'root'
  group 'root'
  mode '0700'
end

vault = ChefVault.new('certs')

node['ssl_certificates'].to_hash.each do |name, certificates|
  certificates = { 'pem' => certificates } unless certificates.is_a?(Hash)

  certificates.each do |extension, certificate|
    file "/etc/ssl/certs/#{name}.#{extension}" do
      owner 'root'
      group 'root'
      mode '0644'
      content certificate
    end
  end

  file "/etc/ssl/private/#{name}.key" do
    owner 'root'
    group 'root'
    mode '0400'
    content vault.certificate("ssl-key-#{name.gsub(/[^a-z0-9]/, '_')}").decrypt_contents
  end
end
