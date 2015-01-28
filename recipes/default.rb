include_recipe "git"
include_recipe "nodejs"
include_recipe "runit"

git node["statsd"]["dir"] do
  repository node["statsd"]["repository"]
  reference node["statsd"]["reference"]
  action :sync
end

directory node["statsd"]["conf_dir"] do
  action :create
end


template "#{node["statsd"]["conf_dir"]}/#{node["statsd"]["config_template_file"]}" do
  mode "0644"
  source "config.js.erb"
  variables(
    :address            => node["statsd"]["address"],
    :port               => node["statsd"]["port"],
    :flush_interval     => node["statsd"]["flush_interval"],
    :percent_threshold  => node["statsd"]["percent_threshold"],
    :graphite_port      => node["statsd"]["graphite_port"],
    :graphite_host      => node["statsd"]["graphite_host"],
    :delete_idle_stats  => node["statsd"]["delete_idle_stats"],
    :delete_gauges      => node["statsd"]["delete_gauges"],
    :delete_timers      => node["statsd"]["delete_timers"],
    :delete_sets        => node["statsd"]["delete_sets"],
    :delete_counters    => node["statsd"]["delete_counters"],
    :legacy_namespace   => node["statsd"]["graphite"]["legacy_namespace"],
    :global_prefix      => node["statsd"]["graphite"]["global_prefix"],
    :global_suffix      => node["statsd"]["graphite"]["global_suffix"],
    :prefix_counter     => node["statsd"]["graphite"]["prefix_counter"],
    :prefix_timer       => node["statsd"]["graphite"]["prefix_timer"],
    :prefix_gauge       => node["statsd"]["graphite"]["prefix_gauge"],
    :prefix_set         => node["statsd"]["graphite"]["prefix_set"],
    :dump_messages      => node["statsd"]["dump_messages"]
  )
end

user node["statsd"]["username"] do
  system true
  shell "/bin/false"
end

runit_service "statsd" do
  action [:enable]
  default_logger true
  options ({
    :user => node['statsd']['username'],
    :statsd_dir => node['statsd']['dir'],
    :conf_dir => node['statsd']['conf_dir'],
    :nodejs_bin => node['statsd']['nodejs_bin']
  })
end
