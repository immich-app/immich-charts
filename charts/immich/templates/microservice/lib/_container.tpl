{{- /* The main container included in the controller */ -}}
{{- define "microservice.controller.mainContainer" -}}
- name: {{ include "microservice.names.fullname" . }}
  image: {{ printf "%s:%s" .Values.microservice.image.repository (default .Chart.AppVersion .Values.microservice.image.tag) | quote }}
  imagePullPolicy: {{ .Values.microservice.image.pullPolicy }}
  {{- with .Values.microservice.command }}
  command:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
      {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.microservice.args }}
  args:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
    {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.microservice.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.lifecycle }}
  lifecycle:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.termination.messagePath }}
  terminationMessagePath: {{ . }}
  {{- end }}
  {{- with .Values.termination.messagePolicy }}
  terminationMessagePolicy: {{ . }}
  {{- end }}

  {{- with .Values.microservice.env }}
  env:
    {{- get (fromYaml (include "microservice.controller.env_vars" $)) "env" | toYaml | nindent 4 -}}
  {{- end }}
  {{- if or .Values.microservice.envFrom .Values.microservice.secret }}
  envFrom:
    {{- with .Values.envFrom }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- if .Values.secret }}
    - secretRef:
        name: {{ include "microservice.names.fullname" . }}
    {{- end }}
  {{- end }}
  ports:
  {{- include "microservice.controller.ports" . | trim | nindent 4 }}
  {{- with (include "microservice.controller.volumeMounts" . | trim) }}
  volumeMounts:
    {{- nindent 4 . }}
  {{- end }}
  {{- include "microservice.controller.probes" . | trim | nindent 2 }}
  {{- with .Values.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}