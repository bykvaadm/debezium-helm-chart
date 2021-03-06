{{/* Expand the name of the chart. */}}
{{- define "debezium.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Create a default fully qualified app name. */}}
{{- define "debezium.fullname" -}}
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

{{/* Create chart name and version as used by the chart label. */}}
{{- define "debezium.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Common labels */}}
{{- define "debezium.labels" -}}
{{ include "debezium.selectorLabels" . }}
managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels */}}
{{- define "debezium.selectorLabels" -}}
app: debezium
{{- end }}

{{/* Create the name of the service account to use */}}
{{- define "debezium.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "debezium.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Define configs offsets statuses topic names */}}
{{- define "debezium.StorageTopicBaseName" -}}
{{- .Values.debezium.env.HISTORY_STORAGE_TOPIC | trimSuffix ".history" }}
{{- end }}
{{- define "debezium.ConfigStorageTopic" -}}
{{ include "debezium.StorageTopicBaseName" . }}.configs
{{- end }}
{{- define "debezium.OffsetStorageTopic" -}}
{{ include "debezium.StorageTopicBaseName" . }}.offsets
{{- end }}
{{- define "debezium.StatusStorageTopic" -}}
{{ include "debezium.StorageTopicBaseName" . }}.statuses
{{- end }}
