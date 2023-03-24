{{- /* The main container included in the controller */ -}}
{{- define "web.controller.mainContainer" -}}
- name: {{ include "web.names.fullname" . }}
  image: {{ printf "%s:%s" .Values.web.image.repository (default .Chart.AppVersion .Values.web.image.tag) | quote }}
  imagePullPolicy: {{ .Values.web.image.pullPolicy }}
  {{- with .Values.web.command }}
  command:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
      {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.web.args }}
  args:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
    {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.web.securityContext }}
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

  {{- with .Values.web.env }}
  env:
    {{- get (fromYaml (include "web.controller.env_vars" $)) "env" | toYaml | nindent 4 -}}
  {{- end }}
  {{- if or .Values.web.envFrom .Values.web.secret }}
  envFrom:
    {{- with .Values.envFrom }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- if .Values.secret }}
    - secretRef:
        name: {{ include "web.names.fullname" . }}
    {{- end }}
  {{- end }}
  {{- include "web.controller.probes" . | trim | nindent 2 }}
  ports:
  {{- include "web.controller.ports" . | trim | nindent 4 }}
{{- end -}}