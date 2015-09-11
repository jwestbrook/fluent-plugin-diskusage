# Fluent::Plugin::Diskusage

Send disk usage per mountpoint as events to FluentD.

## Installation

```ruby
fluent-gem install fluent-plugin-diskusage
```
or

```ruby
/usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-diskusage
```

### Dependencies
This plugin depends on the [sys-filesystem](https://github.com/djberg96/sys-filesystem) ruby gem

## Usage

`refresh_interval` is an optional parameter, by default the plugin will poll every 2 minutes (120 seconds)

`label` is a custom label that will be included in the event record

```
<source>
	type        diskusage
	tag         <YOUR TAG>
	mountpoint  /
	label       rootfs
</source>

<source>
	type             diskusage
	tag              <YOUR TAG>
	mountpoint       /data
	label            DataFiles
	refresh_interval 1800
</source>
```

### Record Format
```
	"label"        => 'rootfs',
	"total_bytes"  => 10737418240
	"free_bytes"   => 6442450944
	"used_bytes"   => 4294967296
	"used_percent" => 0.4
	"free_percent" => 0.6
```
```
	"label"        => 'DataFiles',
	"total_bytes"  => 1099511627775
	"free_bytes"   => 536870912000
	"used_bytes"   => 536870912000
	"used_percent" => 0.5
	"free_percent" => 0.5
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jwestbrook/fluent-plugin-diskusage.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

