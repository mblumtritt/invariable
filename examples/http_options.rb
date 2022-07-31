# frozen_string_literal: true
#
# Sample to use Invariables as complex options.
# See the options used for Net::HTTP.start to refer the sample.
#

require_relative '../lib/invariable'

#
# HTTP Options
# HTTPOptions#to_h is used to generate the options Hash provided to
# Net::HTTP.start (see there).
#
class HTTPOptions
  include Invariable

  attributes :open_timeout,
             :read_timeout,
             :write_timeout,
             :continue_timeout,
             :keep_alive_timeout,
             :close_on_empty_response

  attribute proxy: Invariable.new(:from_env, :address, :port, :user, :pass)

  attribute ssl:
              Invariable.new(
                :ca_file,
                :ca_path,
                :cert,
                :cert_store,
                :ciphers,
                :extra_chain_cert,
                :key,
                :timeout,
                :version,
                :min_version,
                :max_version,
                :verify_callback,
                :verify_depth,
                :verify_mode,
                :verify_hostname
              )

  #
  # Superseded to add some magic and to flatten the Hash provided to eg.
  # Net::HTTP.start.
  #
  def to_h
    # the compact option allows to skip all values of nil and all empty
    # Invariable values
    result = super(compact: true)

    # flatten the SSL options:
    ssl = result[:ssl]
    if ssl
      # automagic :)
      result[:use_ssl] = true
      # prefix two options:
      result[:ssl_timeout] = ssl.delete(:timeout) if ssl.key?(:timeout)
      result[:ssl_version] = ssl.delete(:version) if ssl.key?(:version)
    end

    # flatten the proxy options and prefix the keys
    proxy = result.delete(:proxy)
    if proxy
      result.merge!(proxy.transform_keys! { |key| "proxy_#{key}".to_sym })
    end

    result
  end
end

puts '- create a sample'
sample =
  HTTPOptions.new(
    open_timeout: 2,
    read_timeout: 2,
    write_timeout: 2,
    ssl: {
      timeout: 2,
      min_version: :TLS1_2
    },
    proxy: {
      port: 8080,
      from_env: true
    }
  )
p sample.to_h
