{{- define "debezium.name" -}}
{{- .Release.Name | trimPrefix "debezium-" -}}
{{- end }}

{{- define "debezium.selectorLabels" -}}
app: {{ .Chart.Name }}
connector: {{ include "debezium.name" . }}
{{- end }}

{{- define "debezium.labels" -}}
{{ include "debezium.selectorLabels" . }}
managed-by: {{ .Release.Service | lower }}
{{- end }}
