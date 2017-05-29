require 'sys/filesystem'
require 'fluent/plugin/input'

class Fluent::Plugin::DiskUsage < Fluent::Plugin::Input
	Fluent::Plugin.register_input('diskusage',self)

	helpers :timer

	# Define `router` method to support v0.10.57 or earlier
	unless method_defined?(:router)
		define_method("router") { Fluent::Engine }
	end

	config_param :tag,		:string
	config_param :mountpoint,	:string
	config_param :label,		:string
	config_param :refresh_interval,	:integer, :default => 120

	def configure(conf)
		super
	end

	def start
		super
		timer_execute(:in_diskusage_timer, @refresh_interval, &method(:output))
	end

	def output
		filestats = Sys::Filesystem.stat(@mountpoint)
		total_bytes = filestats.block_size * filestats.blocks
		free_bytes = filestats.block_size * filestats.blocks_available
		used_bytes = total_bytes - free_bytes
		used_percent = 0
		free_percent = 0
		if total_bytes.nonzero?
			used_percent = used_bytes / total_bytes.to_f
			free_percent = free_bytes / total_bytes.to_f
		end
		record = {"label"=>@label,"total_bytes"=>total_bytes,"free_bytes"=>free_bytes,"used_bytes"=>used_bytes,"used_percent"=>used_percent,"free_percent"=>free_percent}

		time = Fluent::Engine.now
		router.emit(tag,time,record)
	end

	def shutdown
		super
	end
end
