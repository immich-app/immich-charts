{{- /* The main container included in the controller */ -}}
{{- define "machine_learning.controller.mainContainer" -}}
- name: {{ include "machine_learning.names.fullname" . }}
  image: {{ printf "%s:%s" .Values.machine_learning.image.repository (default .Chart.AppVersion .Values.machine_learning.image.tag) | quote }}
  imagePullPolicy: {{ .Values.machine_learning.image.pullPolicy }}
  {{- with .Values.machine_learning.command }}
  command:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
      {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.machine_learning.args }}
  args:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
    {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.machine_learning.securityContext }}
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

  {{- with .Values.machine_learning.env }}
  env:
    {{- get (fromYaml (include "machine_learning.controller.env_vars" $)) "env" | toYaml | nindent 4 -}}
  {{- end }}
  {{- if or .Values.machine_learning.envFrom .Values.machine_learning.secret }}
  envFrom:
    {{- with .Values.machine_learning.envFrom }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- if .Values.machine_learning.secret }}
    - secretRef:
        name: {{ include "machine_learning.names.fullname" . }}
    {{- end }}
  {{- end }}
  ports:
  {{- include "machine_learning.controller.ports" . | trim | nindent 4 }}
  {{- with (include "machine_learning.controller.volumeMounts" . | trim) }}
  volumeMounts:
    {{- nindent 4 . }}
  {{- end }}
  {{- include "machine_learning.controller.probes" . | trim | nindent 2 }}
  {{- with .Values.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}