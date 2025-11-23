{{/*
Expand the name of the chart.
*/}}
{{- define "helperapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "helperapp.fullname" -}}
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
{{- define "helperapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "helperapp.labels" -}}
helm.sh/chart: {{ include "helperapp.chart" . }}
{{ include "helperapp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helperapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helperapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "helperapp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "helperapp.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "helperapp.deployment.apiVersion" -}}
{{- print "apps/v1" }}
{{- end }}

{{/*
Return the proper image name
*/}}
{{- define "helperapp.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "helperapp.annotations" -}}
{{- with .Values.podAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Resource limits and requests
*/}}
{{- define "helperapp.resources" -}}
{{- if .Values.resources }}
resources:
  {{- toYaml .Values.resources | nindent 2 }}
{{- end }}
{{- end }}
