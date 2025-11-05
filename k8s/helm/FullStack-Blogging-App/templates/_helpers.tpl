{{-/* Helper template for names */-}}
{{- define "blog.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "blog.labels" -}}
app.kubernetes.io/name: {{ include "blog.name" . | default .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: Helm
{{- end -}}

{{- define "blog.name" -}}
{{- .Chart.Name -}}
{{- end -}}
