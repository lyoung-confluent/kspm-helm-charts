{{/*
Expand the name of the chart.
*/}}
{{- define "k8sosquery.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "k8sosquery.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "k8sosquery.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "k8sosquery.labels" -}}
helm.sh/chart: {{ include "k8sosquery.chart" . }}
{{ include "k8sosquery.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "k8sosquery.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8sosquery.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "k8sosquery.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "k8sosquery.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Namespace identification
*/}}
{{- define "k8sosquery.namespace" -}}
{{- if (ne .Release.Namespace  "default") }}
  namespace: {{ .Release.Namespace }}
{{- else }}
  namespace: {{ .Values.namespace }}
{{- end }}
{{- end }}

{{/*
Get K8sosquery version from image tag.
Beginning K8sosquery version 5.12.2.7 the nginx cert path has been updated.
So this helper function is used to determine if the version present in image_tag is greater than or equal to the change version.
*/}}
{{- define "k8sosquery.version" -}}
{{- $osqueryChangeVersion := dict "0" 5 "1" 12 "2" 2 "3" 7 }}
{{- $imageTag := (split ":" .Values.daemonset.containers.image_name)._1 }}
{{- $versionString := (split "-" $imageTag)._0 }}
{{- $versionMap := split "." $versionString }}
{{- $isVersionGreaterOrEqual := false }}
{{- if or (gt (atoi $versionMap._0) (get $osqueryChangeVersion "0")) (and (eq (atoi $versionMap._0) (get $osqueryChangeVersion "0")) (gt (atoi $versionMap._1) (get $osqueryChangeVersion "1"))) (and (eq (atoi $versionMap._0) (get $osqueryChangeVersion "0")) (eq (atoi $versionMap._1) (get $osqueryChangeVersion "1")) (gt (atoi $versionMap._2) (get $osqueryChangeVersion "2"))) (and (eq (atoi $versionMap._0) (get $osqueryChangeVersion "0")) (eq (atoi $versionMap._1) (get $osqueryChangeVersion "1")) (eq (atoi $versionMap._2) (get $osqueryChangeVersion "2")) (ge (atoi $versionMap._3) (get $osqueryChangeVersion "3"))) }}
{{- $isVersionGreaterOrEqual = true }}
{{- end }}
{{- $isVersionGreaterOrEqual -}}
{{- end }}

{{/*
Add common labels for the chart resources specified in values
*/}}
{{- define "k8sosquery.commonLabels" -}}
{{- with .Values.commonLabels }}
  labels:
  {{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}


{{/*
Add common annotations for the chart resources specified in values
*/}}
{{- define "k8sosquery.commonAnnotations" -}}
{{- with .Values.commonAnnotations }}
  annotations:
  {{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}

{{/*
Add common labels for the chart resources specified in values for resources 
with existing labels
*/}}
{{- define "k8sosquery.appendCommonLabels" -}}
{{- with .Values.commonLabels -}}
{{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}

{{/*
Add common annotations for the chart resources specified in values for resources 
with existing annotations
*/}}
{{- define "k8sosquery.appendCommonAnnotations" -}}
{{- with .Values.commonAnnotations -}}
{{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}

{{/*
Built-in defaults for the osquery flags file.
Each key is an osquery flag name without the leading "--". These are merged with
`configmap.data.flags` from values by the "k8sosquery.flags" helper below.
NOTE: Please consult Uptycs customer support before changing these defaults.
*/}}
{{- define "k8sosquery.defaultFlags" -}}
add_container_image_to_events: false
additional_enroll_sql: ""
additional_logger: ""
allow_inotify_file_events: false
allowed_yara_fim_operation: "open,open+truncate,open+modify,write,rename,rename_to,CREATED,UPDATED,MOVED_TO,symlink,link"
ancestor_list_cmdline_max_length: 200
ancestor_list_max_entries: 6
audit_allow_config: true
audit_allow_fim_events: false
audit_allow_process_events: false
audit_allow_selinux_events: false
audit_allow_sockets: false
audit_allow_syscall_events: false
audit_allow_unix: false
audit_allow_user_events: false
audit_eoe_record_timeout: 0
audit_events_rate: 0
audit_exe_rules_sync: false
audit_exe_rules_sync_period: 10
audit_fim_show_accesses: false
audit_force_dispatcher_mode: false
audit_force_reconfigure: false
audit_records_rate: 10000
audit_rules_sync: 0
audit_rules_sync_period: 10
audit_show_partial_fim_events: false
auditd_service_control: 0
augeas_allow_adhoc_lens: true
augeas_lenses: "/usr/share/osquery/lenses"
aul_events_processes: ""
buffered_log_max: 1000000
carve_upload_timeout: 58
carver_block_size: 5242880
carver_compression: true
carver_continue_endpoint: "/agent/carve_continue"
carver_start_endpoint: "/agent/carve_start"
compliance_data_in_json: false
compliance_data_limit: 10240
config_accelerated_refresh: 900
config_plugin: "tls"
config_refresh: 60
config_tls_endpoint: "/agent/config"
config_tls_max_attempts: 1
containerd_socket: "/run/containerd/containerd.sock"
crio_socket: "/run/crio/crio.sock"
database_path: "/var/osquery/osquery.db"
decorations_top_level: true
delayed_queue_splay: 5
disable_audit: true
disable_auto_memory: false
disable_carver: true
disable_distributed: false
disable_events: false
disable_events_exclusion_count: true
disable_events_filters: ""
disable_events_staging: true
disable_process_carver: true
disable_yara_fast_scan_mode: false
disk_scan_cpu_percent: 5
disk_scan_sleep_duration: 200
distributed_interval: 0
distributed_plugin: "tls"
distributed_tls_max_attempts: 10
distributed_tls_read_endpoint: "/agent/distributed_read"
distributed_tls_write_endpoint: "/agent/distributed_write"
docker_socket: "/run/docker.sock"
ebpf_program_location: "/usr/bin/bpf_progs.o"
enable_aul_events: false
enable_containerd_events: false
enable_curl: false
enable_disk_scan: false
enable_dns_blocking: false
enable_dns_lookups: true
enable_docker_events: false
enable_ebpf_dns_events: false
enable_failed_ebpf_dns_events: false
enable_fs_events_based_file_events: false
enable_http_lookups: false
enable_keyboard_events: false
enable_ldap_events: false
enable_monitor: true
enable_mouse_events: false
enable_ntp_query: false
enable_numeric_monitoring: false
enable_process_blocking: false
enable_process_blocking_events: false
enable_process_event_blocking_decoration: false
enable_proxy_auto_discovery: true
enable_remediation: false
enable_syslog: false
enable_windows_defender_perf_validator: false
enable_windows_kernel_events: true
enable_wmi: true
enable_yara_ad_hoc_rules: false
enable_yara_process_events: false
enable_yara_process_file_events: true
enable_yara_process_scanning: false
enroll_always: true
enroll_secret_path: "/etc/osquery/uptycs.secret"
enroll_skip_tables: ""
enroll_tls_endpoint: "/agent/enroll"
events_max: 1000
exclude_controlling_parents: true
fim_capture_magic_number_bytes: 0
force_legacy_dns_events: false
force_legacy_process_blocking_events: false
force_legacy_process_events: false
generate_process_hash_in_process_event: false
generate_record_hash: true
host_identifier: "uuid"
ignore_network_home_directories: true
include_http_headers: ""
logger_event_type: true
logger_path: "/var/log/osquery"
logger_plugin: "tls"
logger_tls_compress: true
logger_tls_endpoint: "/agent/log"
logger_tls_format: 3
logger_tls_max: 5242880
logger_tls_period: 4
lxd_socket: "/var/lib/lxd/unix.socket"
max_distributed_payload: 5120
max_heartbeat_delay: 1800
max_private_scan_size: 3145728
max_stderr_log_size: 50
max_yara_scan_strings_match: 16384
mft_scan_sleep_duration: 400
min_private_scan_size: 102400
no_install_audit_fim_events_rule: false
no_install_audit_process_events_rule: false
no_install_audit_socket_events_rule: false
override_audit_allow_fim_events: false
pidfile: "/var/run/osqueryd.pid"
proxy_auto_discovery_order: "db, os, flags, direct"
proxy_hostname: ""
redirect_stderr: true
report_all_open_events: false
reset_dns_blocking: true
reset_process_blocking: true
schedule_default_interval: 3600
schedule_max_drift: 60
schedule_reload: 300
schedule_splay_percent: 10
schedule_timeout: 0
software_update: true
sysfs_mountpoint: "/sys"
syslog_events_max: 100000
syslog_pipe_path: "/var/osquery/syslog_pipe"
syslog_rate_limit: 100
threat_indicator_refresh_interval: 7200
tls_hostname: {{ .Values.uptycsCloud | quote }}
tls_threat_indicator_index_interval: 3600
try_audit_based_events_first: false
utc: true
verbose_level: 2
watchdog_above_sixteen_alloc_vm: 32
watchdog_base_alloc_vm: 400
watchdog_base_memory: 2
watchdog_below_sixteen_alloc_vm: 80
watchdog_db_check_interval: 600
watchdog_db_limit: 0
watchdog_level: 0
watchdog_memory_limit: 300
watchdog_utilization_limit: 0
win_allow_amsi_events: false
win_allow_api_blocking: false
win_allow_api_events: false
win_allow_drive_events: true
win_allow_fim_events: true
win_allow_image_events: false
win_allow_logon_events: true
win_allow_powershell_events: false
win_allow_process_control_events: false
win_allow_process_debug_handles: false
win_allow_process_events: true
win_allow_reg_events: false
win_allow_sockets: true
win_allow_wmi_query_events: false
win_amsi_payload_length: 16384
win_enable_advanced_forensics: false
win_enable_dns_lookups: false
win_enable_http_events: false
win_enable_ransomware_detection: true
win_forensics_operations_flags: 1
win_forensics_trigger_path: ""
win_forensics_write_flags: 6
win_ransomware_detection_time_window: 60
win_ransomware_dir_to_watch: 0
win_ransomware_extension_to_watch: 0
win_ransomware_fileop_to_watch: 5
windows_defender_preference_update_interval: 5000
windows_event_channels: "Application,Security,Setup,System"
windows_event_excluded_ids: ""
yara_process_events_min_age: 30
yara_process_events_scan_all_at_startup: true
yara_process_limit_mem_used: 10485760
{{- end }}

{{/*
Render a single osquery flag value.
Numbers reaching a template (from values or fromYaml) are float64, so whole numbers such as
5242880 would otherwise be printed in scientific notation.
*/}}
{{- define "k8sosquery.flagValue" -}}
{{- if and (kindIs "float64" .) (eq (floor .) .) -}}
{{- int64 . -}}
{{- else -}}
{{- . -}}
{{- end -}}
{{- end }}

{{/*
The osquery flags file contents.
Built from "k8sosquery.defaultFlags" with `configmap.data.flags` from values merged over it,
so a flag can be overridden or a new flag added without restating the whole file. A flag set
to null in values is dropped from the rendered file entirely.
*/}}
{{- define "k8sosquery.flags" -}}
{{- $overrides := .Values.configmap.data.flags | default dict -}}
{{- $flags := mergeOverwrite (include "k8sosquery.defaultFlags" . | fromYaml) (deepCopy $overrides) -}}
{{- range $name, $value := $overrides -}}
{{- if kindIs "invalid" $value -}}
{{- $_ := unset $flags $name -}}
{{- end -}}
{{- end -}}
{{- range $name, $value := $flags }}
--{{ $name }}={{ include "k8sosquery.flagValue" $value }}
{{- end }}
{{- end }}
