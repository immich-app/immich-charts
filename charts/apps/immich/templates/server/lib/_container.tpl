{{- /* The main container included in the controller */ -}}
{{- define "server.controller.mainContainer" -}}
- name: {{ include "server.names.fullname" . }}
  image: {{ printf "%s:%s" .Values.server.image.repository (default .Chart.AppVersion .Values.server.image.tag) | quote }}
  imagePullPolicy: {{ .Values.server.image.pullPolicy }}
  {{- with .Values.server.command }}
  command:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
      {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.server.args }}
  args:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
    {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.server.securityContext }}
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

  {{- with .Values.server.env }}
  env:
    {{- get (fromYaml (include "server.controller.env_vars" $)) "env" | toYaml | nindent 4 -}}
  {{- end }}
  {{- if or .Values.server.envFrom .Values.server.secret }}
  envFrom:
    {{- with .Values.envFrom }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- if .Values.secret }}
    - secretRef:
        name: {{ include "server.names.fullname" . }}
    {{- end }}
  {{- end }}
  ports:
  {{- include "server.controller.ports" . | trim | nindent 4 }}
  {{- with (include "server.controller.volumeMounts" . | trim) }}
  volumeMounts:
    {{- nindent 4 . }}
  {{- end }}
  {{- include "server.controller.probes" . | trim | nindent 2 }}
  {{- with .Values.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}