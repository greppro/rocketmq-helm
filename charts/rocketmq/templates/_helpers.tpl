{{/*
Expand the name of the chart.
*/}}
{{- define "rocketmq.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rocketmq.fullname" -}}
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
{{- define "rocketmq.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rocketmq.labels" -}}
helm.sh/chart: {{ include "rocketmq.chart" . }}
{{ include "rocketmq.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rocketmq.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rocketmq.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "rocketmq.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rocketmq.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
configmap
*/}}
{{- define "rocketmq.configmap.fullname" -}}
{{ include "rocketmq.fullname" . }}-server-config
{{- end }}

{{/*
acl configmap
*/}}
{{- define "rocketmq.acl.configmap.fullname" -}}
{{ include "rocketmq.fullname" . }}-acl-cm
{{- end }}

{{/*
broker-cm
*/}}
{{- define "rocketmq.broker.configmap.fullname" -}}
{{ include "rocketmq.fullname" . }}-broker-cm
{{- end }}

{{/*
nameserver
*/}}
{{- define "rocketmq.nameserver.fullname" -}}
{{ include "rocketmq.fullname" . }}-nameserver
{{- end }}

{{/*
proxy
*/}}
{{- define "rocketmq.proxy.fullname" -}}
{{ include "rocketmq.fullname" . }}-proxy
{{- end }}

{{/*
dashboard
*/}}
{{- define "rocketmq.dashboard.fullname" -}}
{{ include "rocketmq.fullname" . }}-dashboard
{{- end }}


{{/*
env NAMESRV_ADDR
*/}}
{{- define "rocketmq.nameserver.addr" -}}
{{- $nsFullName := include "rocketmq.nameserver.fullname" . -}}
{{- $nsReplica := int .Values.nameserver.replicaCount -}}
  {{- range $i := until $nsReplica -}}
  {{- if gt $i 0 }}{{ printf ";" }}{{ end -}}
  {{- printf "%s-%d.%s:9876" $nsFullName $i $nsFullName -}}
  {{- end -}}
{{- end }}
