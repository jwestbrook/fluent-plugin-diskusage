require 'test/unit'
require 'fluent/test'
require 'fluent/test/helpers'
require 'fluent/test/driver/input'
require 'fluent/plugin/in_diskusage'

class DiskUsageTest < Test::Unit::TestCase
  include Fluent::Test::Helpers

  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    tag         raw.diskusage
    mountpoint  /
    label       rootfs
  ]

  CONFIG_REFRESH_INTERVAL = %[
    tag         raw.diskusage
    mountpoint  /
    label       rootfs
    refresh_interval 5
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::DiskUsage).configure(conf)
  end

  class ConfigureTest < self
    def test_default
      d = create_driver
      assert_equal 'raw.diskusage', d.instance.tag
      assert_equal '/', d.instance.mountpoint
      assert_equal 'rootfs', d.instance.label
      assert_equal 120, d.instance.refresh_interval
    end

    def test_refresh_interval
      d = create_driver(CONFIG_REFRESH_INTERVAL)
      assert_equal 'raw.diskusage', d.instance.tag
      assert_equal '/', d.instance.mountpoint
      assert_equal 'rootfs', d.instance.label
      assert_equal 5, d.instance.refresh_interval
    end
  end

  def test_emit
    d = create_driver(CONFIG + %[refresh_interval 1])
    d.run(expect_emits: 1)
    events = d.events
    now = event_time
    assert_equal "raw.diskusage", events[0][0]
    assert_in_delta events[0][1].to_f, now.to_f, 0.5
    assert_equal "rootfs", events[0][2]["label"]
    assert_true events[0][2].has_key?("total_bytes")
    assert_true events[0][2].has_key?("free_bytes")
    assert_true events[0][2].has_key?("used_bytes")
    assert_true events[0][2].has_key?("used_percent")
    assert_true events[0][2].has_key?("free_percent")
  end
end
