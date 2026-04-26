{{/*
Expand the name of the chart
*/}}
{{- define "auth-service.name" -}}
{{- "auth-service" }}
{{- end }}

{{/*
Full name with release
*/}}
{{- define "auth-service.fullname" -}}
{{- printf "%s-%s" .Release.Name "auth-service" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "auth-service.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: auth-service
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: auth
app.kubernetes.io/part-of: kubekitchen
project: {{ .Values.global.project }}
environment: {{ .Values.global.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "auth-service.selectorLabels" -}}
app: auth-service
{{- end }}

{{/*
Image tag - use service specific or fall back to global
*/}}
{{- define "auth-service.imageTag" -}}
{{- if .Values.image.tag -}}
{{- .Values.image.tag -}}
{{- else -}}
{{- .Values.global.imageTag -}}
{{- end -}}
{{- end }}

{{/*
Image pull policy - use service specific or fall back to global
*/}}
{{- define "auth-service.imagePullPolicy" -}}
{{- if .Values.image.pullPolicy -}}
{{- .Values.image.pullPolicy -}}
{{- else -}}
{{- .Values.global.imagePullPolicy -}}
{{- end -}}
{{- end }}

{{/*
Secret checksum - triggers pod restart when secret values change
Uses global values that feed into the secret so any change rotates pods
*/}}
{{- define "auth-service.secretChecksum" -}}
{{- printf "%s-%s-%s" .Values.global.jwtSecret .Values.global.jwtExpiresIn .Values.global.nodeEnv | sha256sum }}
{{- end }}