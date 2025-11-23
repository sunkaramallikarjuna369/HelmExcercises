{{- define "rbacapp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (printf "%s-rbacapp" .Release.Name) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
