{{- /* The main container included in the controller */ -}}
{{- define "proxy.controller.mainContainer" -}}
- name: {{ include "proxy.names.fullname" . }}
  image: {{ printf "%s:%s" .Values.proxy.image.repository (default .Chart.AppVersion .Values.proxy.image.tag) | quote }}
  imagePullPolicy: {{ .Values.proxy.image.pullPolicy }}
  {{- with .Values.proxy.command }}
  command:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
      {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.proxy.args }}
  args:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
    {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.proxy.securityContext }}
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

  {{- with .Values.proxy.env }}
  env:
    {{- get (fromYaml (include "proxy.controller.env_vars" $)) "env" | toYaml | nindent 4 -}}
  {{- end }}
  {{- if or .Values.proxy.envFrom .Values.proxy.secret }}
  envFrom:
    {{- with .Values.envFrom }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- if .Values.secret }}
    - secretRef:
        name: {{ include "proxy.names.fullname" . }}
    {{- end }}
  {{- end }}
  {{- include "proxy.controller.probes" . | trim | nindent 2 }}
  ports:
  {{- include "proxy.controller.ports" . | trim | nindent 4 }}
{{- end -}}