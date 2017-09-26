#!/bin/sh

set -e

mkdir -p /etc/awslogs

cluster=$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .Cluster')
container_instance_id=$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .ContainerInstanceArn' | awk -F/ '{print $2}' )

cat > /etc/awslogs/awscli.conf << EOF
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/dmesg]
file = /var/log/dmesg
log_group_name = /var/log/dmesg
log_stream_name = $cluster/$container_instance_id

[/var/log/messages]
file = /var/log/messages
log_group_name = /var/log/messages
log_stream_name = $cluster/$container_instance_id
datetime_format = %b %d %H:%M:%S

[/var/log/docker]
file = /var/log/docker
log_group_name = /var/log/docker
log_stream_name = $cluster/$container_instance_id
datetime_format = %Y-%m-%dT%H:%M:%S.%f

[/var/log/ecs/ecs-init.log]
file = /var/log/ecs/ecs-init.log.*
log_group_name = /var/log/ecs/ecs-init.log
log_stream_name = {cluster}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/ecs-agent.log]
file = /var/log/ecs/ecs-agent.log.*
log_group_name = /var/log/ecs/ecs-agent.log
log_stream_name = $cluster/$container_instance_id
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/audit.log]
file = /var/log/ecs/audit.log.*
log_group_name = /var/log/ecs/audit.log
log_stream_name = $cluster/$container_instance_id
datetime_format = %Y-%m-%dT%H:%M:%SZ

[calendar/var/log/apache2/access.log]
file = /var/log/nginx/access.log
log_group_name = calendar/var/log/apache2/access.log
log_stream_name = $cluster/$container_instance_id
time_zone = LOCAL
#datetime_format = %Y-%m-%dT%H:%M:%S

[calendar/var/log/apache2/error.log]
file = /var/log/apache2/error.log
log_group_name = calendar/var/log/apache2/error.log
log_stream_name = $cluster/$container_instance_id
time_zone = LOCAL
#datetime_format = %Y-%m-%dT%H:%M:%S
EOF
