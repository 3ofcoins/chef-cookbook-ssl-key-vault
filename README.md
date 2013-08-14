ssl-key-vault cookbook
======================

This cookbook manages OpenSSL key pairs, using
[chef-vault](https://github.com/Nordstrom/chef-vault/) to share and
store private keys.

This cookbook's home is at https://github.com/3ofcoins/ssl-key-vault/

Requirements
------------

Usage
-----

1. Generate a self-signed key or a secret key and certificate.
2. Store the private key in chef-vault. The name should be set to
   *ssl-key-key.name*.:

    $ knife encrypt cert \
      --search 'QUERY' --admins '' \
      --name ssl-key-example.com \
      --cert /path/to/example.com.key
    $ knife upload data_bags/certs
    
   Either add Chef server's admin API users to the `--admins`, or make
   the key otherwise accessible to yourself in future (e.g. with
   [knife-briefcase](https://github.com/3ofcoins/knife-briefcase/)).

3. Add the certificate to node's `ssl_certificates` attribute (key is
   key's name, and value is full certificate):

```ruby
example_com_cert = <<EOF
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
EOF

default_attributes :ssl_certificates => {
  'example.com' => example_com_cert
}
```

If you don't want to clutter your role definition, you can read the
certificate from file in the chef repo:
   
```ruby
default_attributes :ssl_certificates => {
  'example.com' => Pathname.new(__FILE__).dirname.join('../config/certificates/example.com.crt').read
}
```

4. Add `recipe[ssl-key-vault]` to node's run list.

The key will be stored in `/etc/ssl/private/key.name.key`, and
certificate in `/etc/ssl/certs/key.name.pem`.

### Multiple certificate files

If you need to store certificate and chain separately, or store public
part in multiple files for any other reason, the `ssl_certificates`
entry can also be a dictionary, where key is extension of the file in
`/etc/ssl/certs`, and value is the file's content.

```ruby
certificates = Pathname.new(__FILE__).dirname.join('../config/certificates')
default_attributes :ssl_certificates => {
  'example.com' => {
    'crt' => certificates.join('example.com.crt').read,
    'chain.pem' => certificates.join('example.com.chain.pem).read,
  }
}
```

In this example, files `/etc/ssl/certs/example.com.crt` and
`/etc/ssl/certs/example.com.chain.pem` will be created.


TODOs & questions
-----------------

Maybe we should store certificate somewhere else than in attributes?
knife-vault supports only one value, and certificate is public, so it
shouldn't be encrypted. Creating a separate data bag seems to create
a lot of clutter, and is not easy to describe in _Usage_ section, as
it needs to be encoded in JSON. Adding it to cookbook's _files/_ is
also kind of messy.

Maybe the answer would be to script adding a new key. A knife plugin
or at least a Thor task definition may be helpful here.

I don't have much of idea currently how to add tests, with chef-vault,
encrypted data bags, and such.

Author
------

Author:: Maciej Pasternacki <maciej@3ofcoins.net>
