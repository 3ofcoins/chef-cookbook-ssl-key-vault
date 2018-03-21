# Ssl Key Vault
# =============

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

node['ssl_certificates'].to_hash.each do |name, certificates|
  begin
    item = chef_vault_item('certs', "ssl-key-#{name.gsub(/[^a-z0-9]/, '_')}")
  rescue ChefVault::Exceptions::KeysNotFound, ChefVault::Exceptions::SecretDecryption
    node.save # ~FC075
    raise
  end

  certificates =
    case certificates
    when false then next
    when true then item.to_hash
    when String then { 'key' => item['contents'], 'pem' => certificate }
    when Hash then certificates.merge( {'key' => item['contents'] } )
    else raise "Don't know what to do with certificate for #{name} (#{certificates.inspect})"
    end

  %w[chef_type data_bag id].each do |attr|
    certificates.delete attr
  end

  file "/etc/ssl/private/#{name}.key" do
    owner 'root'
    group 'root'
    mode '0400'
    content certificates.delete('key')
  end

  certificates.each do |extension, certificate|
    file "/etc/ssl/certs/#{name}.#{extension}" do
      owner 'root'
      group 'root'
      mode '0644'
      content certificate
    end
  end
end
