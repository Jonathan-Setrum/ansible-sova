open("/srv/rails/sova/shared/system/urls.yml", "w") do |f|
  f.puts "# #{DateTime.now.to_s}"
  f.puts Vserver.where(state: "online").includes(:subscription).includes(:subscription => :plan).includes(:cdn).collect{|v|
    {
      id: v.subscription.id,
      user_id: v.subscription.user_id,
      hostname: v.hostname,
      default_hostname: v.default_hostname,
      ip: v.ip,
      cdn: (v.cdn.present? and v.cdn.domain_name.respond_to?(:split) ? v.cdn.domain_name.split("\n") : false),
      phpmyadmin: v.pmode,
      cache: v.cmode,
      sftpuser: v.username,
      plan: v.subscription.plan.full_name,
      label: "#{v.hostname} (##{v.subscription.id})",
    }
  }.to_yaml
end
